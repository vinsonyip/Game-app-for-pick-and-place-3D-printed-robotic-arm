import cv2
import numpy as np
from flask import Flask, jsonify, request
import json
import base64

# Player must use white chess to play the game


def scanChessBoard(path_standardChessboard,path_currentChessboard):
    # This image is for the chessboard grid detection, this image must be correctly detected by AI program
    img = cv2.imread(path_standardChessboard, cv2.IMREAD_COLOR)
    # Define width and height of window
    width = 500
    height = 500

    # Resized the image
    resized = cv2.resize(img,(width,height),cv2.INTER_AREA)
    # Convert the image to gray-scale
    gray = cv2.cvtColor(resized, cv2.COLOR_BGR2GRAY)
    # Find the edges in the image using canny detector
    edges = cv2.Canny(gray, 50, 200)
    # Detect points that form a line
    # cv2.HoughLinesP(image,rho, theta, threshold, np.array ([ ]), minLineLength=xx, maxLineGap=xx)
    # change the threshold(80-100) value if the computer can't recognize the grid
    lines = cv2.HoughLinesP(edges, 1, np.pi/180,90 , minLineLength=100, maxLineGap=250)
    # Draw lines on the image
    for line in lines:
        x1, y1, x2, y2 = line[0]
        cv2.line(resized, (x1, y1), (x2, y2), (255, 0, 0), 2)

    for x in range(500):
        for y in range(500):
            b,g,r = (resized[y,x])
            if(b==255 and g==0 and r==0):
                resized[y,x] = [0,0,0]
            else:
                resized[y,x] = [255,255,255]
    #cv2.imshow('resized',resized)
    #cv2.waitKey(0)
    cv2.imwrite('resized.png',resized)
    im = cv2.imread('resized.png')
    imgray = cv2.cvtColor(im, cv2.COLOR_BGR2GRAY)
    ret, thresh = cv2.threshold(imgray, 127, 255, 0)
    contours, hierarchy = cv2.findContours(thresh, cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)
    cv2.drawContours(im,contours,-1,(0,255,0),3)

    for x in range(500):
        for y in range(500):
            b,g,r = (im[y,x])
            if((b==0 and g==255 and r==0)or(b==0 and g==0 and r==0)):
                im[y,x] = [0,0,0]
            else:
                im[y,x] = [255,255,255]


    cv2.imwrite('resized.png',im)


    listOfGrids = [] # chessboard size = 64
    #[x axis,y axis, white_OR_black] -> white = 1, black = 0
    tmpList_x = [] # grids x-axis
    tmpList_y = [] # grids y-axis

    ####### Indexing each grid of chessboard ######
    img = cv2.imread('resized.png')
    imgGrey = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    _, thrash = cv2.threshold(imgGrey, 240, 255, cv2.THRESH_BINARY)
    contours, _ = cv2.findContours(thrash, cv2.RETR_TREE, cv2.CHAIN_APPROX_NONE)

    averageWidth = 0
    averageHeight = 0
    count = 0
    for contour in contours:
        approx = cv2.approxPolyDP(contour, 0.01* cv2.arcLength(contour, True), True)
        cv2.drawContours(img, [approx], 0, (0, 0, 0), 1)
        if len(approx) == 4:
            x1 ,y1, w, h = cv2.boundingRect(approx)
            #find average width to filter some shape
            averageWidth += w
            averageHeight += h
        count += 1

    averageWidth = averageWidth/count
    averageHeight = averageHeight/count

    count = 63 # 8*8 chessboard
    for contour in contours:
        approx = cv2.approxPolyDP(contour, 0.01* cv2.arcLength(contour, True), True)
        cv2.drawContours(img, [approx], 0, (0, 0, 0), 1)
        x = approx.ravel()[0]+25 # +15 Sould be changed, when the grid size changed
        y = approx.ravel()[1]+20 # +30 Sould be changed, when the grid size changed
        if len(approx) == 4:
            x1 ,y1, w, h = cv2.boundingRect(approx)
            if w>=averageWidth/2 and h>=averageHeight/1.5:
                  cv2.putText(img, str(count), (x, y), cv2.FONT_HERSHEY_COMPLEX, 0.5, (0, 0, 0))
                  tmpList_x.append(x.item())
                  tmpList_y.append(y.item())
                  
                  count -= 1
    # Indexing each grid of chessboard
    #cv2.imshow("shapes", img)
    #cv2.waitKey(0)

    # Print all coordinates of grids
    tmpList_x.reverse()
    tmpList_y.reverse()

    for i in range(len(tmpList_x)):
        listOfGrids.append([tmpList_x[i],tmpList_y[i],-1])
    ######


    ###### Find white chess by contour and blacken the noise pixel ######

    ## crop_y,crop_x,crop_h,crop_w all need to be changed based on the image!!!
    width = 800
    height = 800
    width2 = 500
    height2 = 500
    crop_y = 83
    crop_x = 180
    crop_h = 303
    crop_w = 430

    print("processing whitechess coordinate...")
    ## Crop an image
    chessBoardImage = cv2.imread(path_currentChessboard)
    chessBoardImage = cv2.resize(chessBoardImage,(width,height),cv2.INTER_AREA)

    chessBoardImage = chessBoardImage[crop_y:crop_y+crop_h, crop_x:crop_x+crop_w]
    chessBoardImage = cv2.resize(chessBoardImage,(width2,height2),cv2.INTER_AREA)

    cv2.imwrite('default_chessboard_image.jpg',chessBoardImage)
    whiteChessImage = cv2.imread("default_chessboard_image.jpg")
    ##
    '''
    cv2.imshow("shapes", whiteChessImage)
    cv2.waitKey(0)
    cv2.destroyAllWindows()
    '''
    for x in range(500):
        for y in range(500):
            b,g,r = (whiteChessImage[y,x])
            if(b<150 or g<180): # in lab b<150 can detect the chess, in home b<240
                whiteChessImage[y,x] = [0,0,0]
    for x in range(500):
        for y in range(500):
            b,g,r = (whiteChessImage[y,x])
            if(r>150): 
                whiteChessImage[y,x] = [255,255,255]
    '''
    cv2.imshow("shapes", whiteChessImage)
    cv2.waitKey(0)
    cv2.destroyAllWindows()
    '''
    imgGrey = cv2.cvtColor(whiteChessImage, cv2.COLOR_BGR2GRAY)
    _, thrash = cv2.threshold(imgGrey, 240, 255, cv2.THRESH_BINARY)
    contours, _ = cv2.findContours(thrash, cv2.RETR_TREE, cv2.CHAIN_APPROX_NONE)


    # Find average area
    averageArea = 0
    count = 0

    for contour in contours:
        approx = cv2.approxPolyDP(contour, 0.01* cv2.arcLength(contour, True), True)
        cv2.drawContours(whiteChessImage, [approx], 0, (0, 0, 0), 5)
        averageArea += cv2.contourArea(contour)
        count += 1

    averageArea/=count
    count = 0

    #Find if white chess in the grid

    for i in range(len(listOfGrids)):
        x = listOfGrids[i][0]
        y = listOfGrids[i][1]
        b,g,r = whiteChessImage[y,x]
        if(b==255 and g==255 and r==255):
            listOfGrids[i][2] = 1
            #cv2.putText(whiteChessImage, "tick", (x, y), cv2.FONT_HERSHEY_COMPLEX, 0.5, (0, 255, 0))
    #print(listOfGrids)
    '''
    cv2.imshow("shapes", whiteChessImage)
    cv2.waitKey(0)
    cv2.destroyAllWindows()
    '''
    # Find white chess by contour and blacken the noise pixel #

    print("processing blackchess coordinate...")

    # testing area #

    blackChessImg = cv2.imread("default_chessboard_image.jpg")
    blackChessImg = cv2.fastNlMeansDenoisingColored(blackChessImg,None,10,10,7,21)

    for x in range(500):
        for y in range(500):
            b,g,r = (blackChessImg[y,x])
            if(b>60 and b<130 and g >75 and g<150 and r>130 and r<180):
                blackChessImg[y,x] = [0,0,0]
            else:
                if(r>75):
                    blackChessImg[y,x] = [0,0,0]
                else:
                    blackChessImg[y,x] = [255,255,255]

    imgGrey = cv2.cvtColor(blackChessImg, cv2.COLOR_BGR2GRAY)
    _, thrash = cv2.threshold(imgGrey, 240, 255, cv2.THRESH_BINARY)
    contours, _ = cv2.findContours(thrash, cv2.RETR_TREE, cv2.CHAIN_APPROX_NONE)


    # Find average area
    averageArea = 0
    count = 0
    for i in range(len(listOfGrids)):
        x = listOfGrids[i][0]
        y = listOfGrids[i][1]
        b,g,r = blackChessImg[y,x]
        if(b==255 and g==255 and r==255):
            listOfGrids[i][2] = 0
            #cv2.putText(blackChessImg, "tick", (x, y), cv2.FONT_HERSHEY_COMPLEX, 0.5, (0, 255, 0))
    '''
    cv2.imshow("shapes", blackChessImg)
    cv2.waitKey(0)
    cv2.destroyAllWindows()
    '''



    print(type(listOfGrids[0][0]))

    #cv2.imshow("shapes", blackChessImg)
    #cv2.waitKey(0)
    cv2.destroyAllWindows()
    return listOfGrids

path_standardChessboard = 'C:/Users/VinsonYip/Documents/chessboard4.jpg'
path_currentChessboard = 'C:/Users/VinsonYip/Documents/standard_chessboard_pos.jpg'


#declared an empty variable for reassignment
response = ''
#creating the instance of our flask application
app = Flask(__name__)

@app.route('/image', methods = ['GET', 'POST'])
def imageRoute():

    #fetching the global response variable to manipulate inside the function
    global response
    global listOfGrids

    #checking the request type we get from the app
    if(request.method == 'POST'):
        request_data = request.data #getting the response data
        request_data = json.loads(request_data.decode('utf-8')) #converting it from json to key value pair
        base64_img = request_data['image'] #assigning it to name
        base64_img_bytes = base64_img.encode('utf-8')
        with open('decoded_image.png', 'wb') as file_to_save:
            decoded_image_data = base64.decodebytes(base64_img_bytes)
            file_to_save.write(decoded_image_data)
        path_currentChessboard = 'decoded_image.png'
        
        listOfGrids = scanChessBoard(path_standardChessboard,path_currentChessboard)

        
        return " " #to avoid a type error 
    else:
        return jsonify({'image' : json.dumps(listOfGrids)}) #sending data back to your frontend app



if __name__ == "__main__":
    app.run(host = '10.68.187.245',port=5000)


# testing area #

