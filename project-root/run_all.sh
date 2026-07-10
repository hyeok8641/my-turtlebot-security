#!/bin/bash

# ==========================================================
# 🚀 터틀봇3 홈 시큐리티 시스템 올인원 원터치 기동 스크립트
# ==========================================================

# 💡 터틀봇 IP 주소 설정 (실제 터틀봇 IP와 맞는지 꼭 확인!)
TURTLEBOT_IP="192.168.0.12"
TURTLEBOT_USER="ubuntu"

echo "===================================================="
echo "🔒 홈 시큐리티 시스템 원터치 자동 기동을 시작합니다."
echo "===================================================="

# 1. 기존에 켜져있을지 모르는 백그라운드 세션 종료
tmux kill-session -t security 2>/dev/null

# 2. 'security'라는 이름의 새로운 tmux 세션 생성 (첫 번째 창: Nav2 구동)
# 💡 수정 완료: 누락 방지를 위해 사용하시는 실제 지도 파일명(my_50_room_map.yaml)으로 변경했습니다.
tmux new-session -d -s security -n 'Nav2'
tmux send-keys -t security:Nav2 "export TURTLEBOT3_MODEL=burger" C-m
tmux send-keys -t security:Nav2 "ros2 launch turtlebot3_navigation2 navigation2.launch.py map:=\$HOME/my_50_room_map.yaml" C-m
echo "▶️ [3번 창] 노트북 내비게이션(Nav2) 및 실제 지도(my_50_room_map) 가동 완료."

# 3. 두 번째 창: 터틀봇 본체 Bringup (SSH 원격 접속 후 실행)
tmux new-window -t security -n 'Bringup'
tmux send-keys -t security:Bringup "ssh ${TURTLEBOT_USER}@${TURTLEBOT_IP}" C-m
sleep 1.5
tmux send-keys -t security:Bringup "ros2 launch turtlebot3_bringup robot.launch.py" C-m
echo "▶️ [1번 창] 터틀봇 본체 Bringup 원격 실행 완료."

# 4. 세 번째 창: Rosbridge 가동 (SSH 원격 접속 후 실행)
tmux new-window -t security -n 'Rosbridge'
tmux send-keys -t security:Rosbridge "ssh ${TURTLEBOT_USER}@${TURTLEBOT_IP}" C-m
sleep 1.5
tmux send-keys -t security:Rosbridge "ros2 launch rosbridge_server rosbridge_websocket_launch.xml" C-m
echo "▶️ [2번 창] 웹소켓 Rosbridge 원격 가동 완료."

# 5. 네 번째 창: Patrol Node 가동 (SSH 원격 접속 후 실행)
tmux new-window -t security -n 'Patrol'
tmux send-keys -t security:Patrol "ssh ${TURTLEBOT_USER}@${TURTLEBOT_IP}" C-m
sleep 1.5
tmux send-keys -t security:Patrol "cd ~/turtlebot3_ws && source install/setup.bash" C-m
tmux send-keys -t security:Patrol "ros2 run home_security_pkg patrol_node" C-m
echo "▶️ [4번 창] 순찰 마스터 노드(patrol_node) 기동 완료."

echo "----------------------------------------------------"
echo "✅ 모든 노드가 새로운 지도를 기반으로 기동되었습니다."
echo "💡 (모니터링 화면을 탈출하려면: 'Ctrl + B' 누른 후 'D' 키 입력)"
echo "----------------------------------------------------"
sleep 1

# 관리자가 로그를 볼 수 있도록 메인 Patrol 실행 창 화면으로 전환 및 접속
tmux select-window -t security:Patrol
tmux attach-session -t security
