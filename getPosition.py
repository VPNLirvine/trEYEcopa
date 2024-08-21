import cv2
import numpy as np
import csv
import os 

video_name = 'Q5_6644_argue_and_door_slam.mov' # eventually do this in a loop
file_out = os.path.splitext(video_name)[0] + '.csv' # change extension

def detect_shapes(frame):
    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    blurred = cv2.GaussianBlur(gray, (5, 5), 0)
    edged = cv2.Canny(blurred, 50, 150)
    contours, _ = cv2.findContours(edged, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    shapes = []
    for contour in contours:
        if cv2.contourArea(contour) > 50: #can change to other numbers, this is just filtering small contour.
            # approx = cv2.approxPolyDP(contour, 0.04 * cv2.arcLength(contour, True), True)
            x, y, w, h = cv2.boundingRect(contour)
            # approxArea = cv2.contourArea(approx)
            rect = cv2.minAreaRect(contour)
            rectArea = cv2.contourArea(cv2.boxPoints(rect))
            triArea, tri = cv2.minEnclosingTriangle(contour)
            tri = np.int32(tri)
            (cirX, cirY), cirRad = cv2.minEnclosingCircle(contour)
            cirArea = np.pi * cirRad ** 2
            
            # Determine shape by comparing areas
            # Also draw an appropriate bounding contour in a unique color
            if (triArea < cirArea) and (triArea < rectArea):
                # It's a triangle. But which one?
                if triArea < 2000:
                    shape_type = "littleTriangle"
                    cv2.drawContours(frame, [tri], -1, (0, 128, 255), 2) # orange
                else:
                    shape_type = "bigTriangle"
                    cv2.drawContours(frame, [tri], -1, (0, 255, 0), 2) # green
                triM = cv2.moments(tri)
                X = int(triM["m10"] / triM["m00"])
                Y = int(triM["m01"] / triM["m00"])
            elif (cirArea < triArea) and (cirArea < rectArea):
                shape_type = "Circle"
                X = int(cirX)
                Y = int(cirY)
                cv2.circle(frame, (X, Y), int(cirRad), (255, 0, 0), 2) # circle in blue
            elif (rectArea < triArea) and (rectArea < cirArea):
                shape_type = "House"
                X = x + w//2
                Y = y + h//2
                box = cv2.boxPoints(rect)
                box = box.reshape((-1, 1, 2))
                box = np.int32(box)
                cv2.drawContours(frame, [box], -1, (0, 255, 255), 2) # slanted box in cyan
            else:
                shape_type = "Unknown"
                cv2.rectangle(frame, (x, y), (x + w, y + h), (0, 0, 255), 2) # OG box in red
                X = x + w//2
                Y = y + h//2
            # Specify outputs
            bbox = (x, y, w, h)
            _, _, Angle = rect
            shapes.append((contour, shape_type, bbox, X, Y, int(Angle)))
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
            # If the list of bounding boxes is empty,
            # but we previously had been tracking some object(s),
            # wait until it's been gone for 50 frames before dropping it.
            for objectID in list(self.disappeared.keys()):
                self.disappeared[objectID] += 1
                if self.disappeared[objectID] > 50:
                    self.deregister(objectID)
            return self.objects
        if len(self.objects) == 0:
            # If nothing is currently being tracked,
            # but we drew a bounding box around something,
            # then register each bounding box as a new object.
            for i in range(len(inputBboxes)):
                self.register(inputBboxes[i])
        else:
            objectIDs = list(self.objects.keys())
            objectBboxes = list(self.objects.values())
            inputCentroids = [(bbox[1], bbox[2]) for bbox in inputBboxes]
            objectCentroids = [(bbox[1], bbox[2]) for bbox in objectBboxes]
            # Track the change in location of each object's centroid
            # by measuring the distances to each centroid in the new frame
            # and assuming the shortest distance means the same object
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

vidWidth = cap.get(3)
vidHeight = cap.get(4)
outWidth = 4000
outHeight = 3000

while cap.isOpened():
    ret, frame = cap.read()
    if not ret:
        break
    shapes = detect_shapes(frame)
    bboxes = []
    for contour, shape_type, bbox, X, Y, Angle in shapes:
        x, y, w, h = bbox
        # Write a label above each shape
        cv2.putText(frame, shape_type, (x + 40, y - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 0, 0), 2)
        # cv2.drawContours(frame, [contour], -1, (0, 255, 0), 2)
        
        bboxes.append((bbox, X, Y, Angle))
    objects = tracker.update(bboxes)
    for (objectID, bbox) in objects.items():
        (x, y, w, h), X, Y, Angle = bbox
        text = "ID {}".format(objectID)
        cv2.putText(frame, text, (x, y - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 0), 2)
        # cv2.rectangle(frame, (x, y), (x + w, y + h), (0, 255, 0), 2)
        # cv2.drawContours(frame, [box], -1, (0, 255, 0), 2)
        # position_data.append([frame_count, objectID, x, y, w, h])
        position_data.append([frame_count, objectID, X, Y, Angle])
    cv2.imshow("Frame", frame)
    frame_count += 1
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break
cap.release()
cv2.destroyAllWindows()
cv2.waitKey(1) # this allows it to close the window on Mac

# Rescale values

# Save results to disk
path_out = os.path.normpath('Analysis/posDatOpenCV')
fout = os.path.join(path_out, file_out)
if not os.path.exists(path_out):
    # Ensure path exists before writing to it
    os.makedirs(path_out)
with open(fout, 'w', newline='') as file:
    writer = csv.writer(file)
    # writer.writerow(["Frame", "ObjectID", "X", "Y", "W", "H"])
    writer.writerow(["Frame", "ObjectID", "X", "Y", "Angle"])
    writer.writerows(position_data)