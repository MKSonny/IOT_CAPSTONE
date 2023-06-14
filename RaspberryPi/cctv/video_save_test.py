import cv2
import time

capture = cv2.VideoCapture(0)

# 동영상 프레임 크기, FPS 정보 가져오기
frame_size = (int(capture.get(cv2.CAP_PROP_FRAME_WIDTH)),
              int(capture.get(cv2.CAP_PROP_FRAME_HEIGHT)))
fps = int(capture.get(cv2.CAP_PROP_FPS))

# 저장할 동영상 파일 열기
fourcc = cv2.VideoWriter_fourcc(*'mp4v')
out = None
start_time = None

while True:
    ret, frame = capture.read()
    if not ret:
        break

    # 현재 시간 구하기
    now = time.time()

    # 저장 버튼이 눌리면 동영상 저장
    key = cv2.waitKey(1) & 0xFF
    if key == ord('s'):
        # 이전에 저장 중이던 동영상 파일 닫기
        if out is not None:
            out.release()

        # 새로운 동영상 파일 열기
        filename = f'output_{now}.mp4'
        out = cv2.VideoWriter(filename, fourcc, fps, frame_size)
        start_time = now

    # 10초 단위로 동영상 저장
    if out is not None and now - start_time > 10:
        out.release()
        out = None

    # 동영상 저장 중이면 프레임 저장
    if out is not None:
        out.write(frame)

    # 영상 화면에 보여주기
    cv2.imshow('Video', frame)

    # 종료 버튼이 눌리면 종료
    if key == ord('q'):
        break

# 파일 닫기
capture.release()
cv2.destroyAllWindows()