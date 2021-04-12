import cv2
import numpy as np

#print all event in directory
"""
events = [i for i in dir(cv2) if 'EVENT' in i]
print(events)
"""

def click_event(event,x,y,flags,param):
    if event == cv2.EVENT_LBUTTONDOWN:
        print(x,',',y)
        font = cv2.FONT_HERSHEY_SIMPLEX
        strXY = str(x)+','+str(y)
        cv2.putText(resized,strXY,(x,y),font,0.5,(255,255,0),1)#BGR format
        cv2.imshow('image',resized)
    if event == cv2.EVENT_RBUTTONDOWN:
        # img[y,x,color chanel] - get the color of specific coord of the image
        blue = resized[y,x,0] # 0 is blue channel - BGR
        green = resized[y,x,1] 
        red = resized[y,x,2]
        font = cv2.FONT_HERSHEY_SIMPLEX
        strXY = str(blue)+','+str(green)+','+ str(red)
        print(strXY)
        cv2.putText(resized,strXY,(x,y),font,0.2,(0,255,255),1)#BGR format
        cv2.imshow('image',resized)
        
width = 800
height = 800



#np.zeros(([height],[width],[elements number for each list]))
'''
img = np.zeros((512,512,3),np.uint8) # a black background
'''
img = cv2.imread('C:/Users/VinsonYip/Desktop/default_chessboard_image.jpg',1)

resized = cv2.resize(img,(width,height),cv2.INTER_AREA)

cv2.imshow('image',resized)

# the window name must all the same
cv2.setMouseCallback('image',click_event)

cv2.waitKey(0)
cv2.destroyAllWindows()
