# Calculate optical flow of a given video
# Input is the path/name of a video file
# Output is a vector describing the overall motion frame-by-frame

import cv2
import os
import numpy as np
import csv

# Read the video
video_name = 'Q71_6716_knock_and_hide.mov'
video_path = os.path.normpath('stims/TriCOPA/normal/')
fname = os.path.join(video_path, video_name)
cap = cv2.VideoCapture(fname)
frame_count = 0
numFrames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
# output = np.zeros((numFrames, 1))
output = []
file_out = os.path.splitext(video_name)[0] + '.csv' # change extension

# Set up before actually running the video:
# Parameters for Shi-Tomasi corner detection (gives us something to track)
feature_params = dict( maxCorners = 100,
                       qualityLevel = 0.02,
                       minDistance = 7,
                       blockSize = 7 )
# Parameters for Lucas-Kanade optical flow
lk_params = dict( winSize  = (15, 15),
                  maxLevel = 2,
                  criteria = (cv2.TERM_CRITERIA_EPS | cv2.TERM_CRITERIA_COUNT, 10, 0.03))
# Find corners of first frame
ret, old_frame = cap.read()
old_gray = cv2.cvtColor(old_frame, cv2.COLOR_BGR2GRAY)
p0 = cv2.goodFeaturesToTrack(old_gray, mask = None, **feature_params)

# Create a mask image for drawing purposes
color = np.random.randint(0, 255, (100, 3))
mask = np.zeros_like(old_frame)

# Play video and detect motion
while cap.isOpened():
    ret, frame = cap.read()
    if not ret:
        break
    frame_gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    
    # calculate optical flow
    p1, st, err = cv2.calcOpticalFlowPyrLK(old_gray, frame_gray, p0, None, **lk_params)
    
    # Select good points
    if p1 is not None:
        good_new = p1[st==1]
        good_old = p0[st==1]
    # Draw trails between old and new positions
    for i, (new, old) in enumerate(zip(good_new, good_old)):
        a, b = new.ravel()
        c, d = old.ravel()
        mask = cv2.line(mask, (int(a), int(b)), (int(c), int(d)), color[i].tolist(), 2)
        frame = cv2.circle(frame, (int(a), int(b)), 5, color[i].tolist(), -1)
    img = cv2.add(frame, mask)
    # Calculate total motion and export
    # output[frame_count] = np.sum(np.linalg.norm(good_new - good_old))
    motion = np.sum(np.linalg.norm(good_new - good_old))
    output.append([frame_count, motion])
    # Display
    cv2.imshow("Frame", img)
    frame_count += 1
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break
    # Update what's considered "old" before moving to next frame
    old_gray = frame_gray.copy()
    p0 = good_new.reshape(-1, 1, 2)
cap.release()
cv2.destroyAllWindows()
cv2.waitKey(1) # this allows it to close the window on Mac

# Export the data for this video
path_out = os.path.normpath('Analysis/motionData')
fout = os.path.join(path_out, file_out)
if not os.path.exists(path_out):
    # Ensure path exists before writing to it
    os.makedirs(path_out)
with open(fout, 'w', newline='') as file:
    writer = csv.writer(file)
    # writer.writerow(["Frame", "ObjectID", "X", "Y", "W", "H"])
    writer.writerow(["Frame", "Motion"])
    writer.writerows(output)