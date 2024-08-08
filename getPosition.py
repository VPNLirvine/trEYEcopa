import cv2
import numpy as np
import csv
import os 

video_name = 'Q5_6644_argue_and_door_slam.mov' # eventually do this in a loop

def detect_shapes(frame):
    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    blurred = cv2.GaussianBlur(gray, (5, 5), 0)
    edged = cv2.Canny(blurred, 50, 150)
    contours, _ = cv2.findContours(edged, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    shapes = []
    for contour in contours:
        if cv2.contourArea(contour) > 50: #can change to other numbers, this is just filtering small contour.
            approx = cv2.approxPolyDP(contour, 0.04 * cv2.arcLength(contour, True), True)
            x, y, w, h = cv2.boundingRect(contour)
            if len(approx) == 3:
                shape_type = "Triangle"
            elif len(approx) == 4:
                shape_type = "Quadrilateral"
            elif len(approx) > 4:
                shape_type = "Circle"
            else:
                shape_type = "Unknown"
            shapes.append((contour, shape_type, x, y, w, h))
    return shapes
class BoundaryTracker:
    def __init__(self):
        self.nextObjectID = 0
        self.objects = {}
        self.disappeared = {}
    def register(self, bbox):
        self.objects[self.nextObjectID] = bbox
        self.disappeared[self.nextObjectID] = 0
        self.nextObjectID += 1
    def deregister(self, objectID):
        del self.objects[objectID]
        del self.disappeared[objectID]
    def update(self, inputBboxes):
        if len(inputBboxes) == 0:
            for objectID in list(self.disappeared.keys()):
                self.disappeared[objectID] += 1
                if self.disappeared[objectID] > 50:
                    self.deregister(objectID)
            return self.objects
        if len(self.objects) == 0:
            for i in range(len(inputBboxes)):
                self.register(inputBboxes[i])
        else:
            objectIDs = list(self.objects.keys())
            objectBboxes = list(self.objects.values())
            inputCentroids = [(bbox[0] + bbox[2]//2, bbox[1] + bbox[3]//2) for bbox in inputBboxes]
            objectCentroids = [(bbox[0] + bbox[2]//2, bbox[1] + bbox[3]//2) for bbox in objectBboxes]
            D = np.linalg.norm(np.array(objectCentroids)[:, np.newaxis] - np.array(inputCentroids), axis=2)
            rows = D.min(axis=1).argsort()
            cols = D.argmin(axis=1)[rows]
            usedRows = set()
            usedCols = set()
            for (row, col) in zip(rows, cols):
                if row in usedRows or col in usedCols:
                    continue
                objectID = objectIDs[row]
                self.objects[objectID] = inputBboxes[col]
                self.disappeared[objectID] = 0
                usedRows.add(row)
                usedCols.add(col)
            unusedRows = set(range(0, D.shape[0])).difference(usedRows)
            unusedCols = set(range(0, D.shape[1])).difference(usedCols)
            if D.shape[0] >= D.shape[1]:
                for row in unusedRows:
                    objectID = objectIDs[row]
                    self.disappeared[objectID] += 1
                    if self.disappeared[objectID] > 50:
                        self.deregister(objectID)
            else:
                for col in unusedCols:
                    self.register(inputBboxes[col])
        return self.objects
    
## Begin script portion
video_path = os.path.normpath('stims/TriCOPA/normal/')
fname = os.path.join(video_path, video_name)
cap = cv2.VideoCapture(fname)

tracker = BoundaryTracker()
frame_count = 0
position_data = []

while cap.isOpened():
    ret, frame = cap.read()
    if not ret:
        break
    shapes = detect_shapes(frame)
    bboxes = []
    for contour, shape_type, x, y, w, h in shapes:
        cv2.putText(frame, shape_type, (x + 40, y - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 0, 0), 2)
        cv2.drawContours(frame, [contour], -1, (0, 255, 0), 2)
        bboxes.append((x, y, w, h))
    objects = tracker.update(bboxes)
    for (objectID, bbox) in objects.items():
        x, y, w, h = bbox
        text = "ID {}".format(objectID)
        cv2.putText(frame, text, (x, y - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 0), 2)
        cv2.rectangle(frame, (x, y), (x + w, y + h), (0, 255, 0), 2)
        position_data.append([frame_count, objectID, x, y, w, h])
    cv2.imshow("Frame", frame)
    frame_count += 1
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break
cap.release()
cv2.destroyAllWindows()
cv2.waitKey(1) # this allows it to close the window on Mac

with open('position_data.csv', 'w', newline='') as file:
    writer = csv.writer(file)
    writer.writerow(["Frame", "ObjectID", "X", "Y", "W", "H"])
    writer.writerows(position_data)