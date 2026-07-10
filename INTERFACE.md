# 🔗 프로젝트 토픽 인터페이스 정의서 — 3조

본 프로젝트의 데이터 흐름과 노드 간 통신을 제어하기 위해 3조 조원 전원이 합의한 최종 토픽 인터페이스 명세서입니다.

| 토픽명 | 메시지 타입 | 발행자 (Publisher) | 구독자 (Subscriber) | 주기 | 성격 | QoS | 설명 |
|---|---|---|---|---|---|---|---|
| `/cmd_vel` | geometry_msgs/msg/Twist | `navigation2` / `patrol_node` | `turtlebot3_node` | 10Hz | 연속 | RELIABLE | 로봇의 실제 이동 속도 및 회전 속도 제어 명령 |
| `/detection_msg` | std_msgs/msg/String | `web_bridge` (AI) | `patrol_node` | 변화 시 | 엣지 | RELIABLE | 스마트폰 AI가 감지한 상태값 (`safe` 또는 `fire`) 발행 |
| `/mode_status` | std_msgs/msg/String | `patrol_node` | `web_bridge` (대시보드) | 5Hz | 연속 | BEST_EFFORT | 대시보드 전광판에 표시할 로봇의 현재 상태 (`INIT` / `PATROL` / `EMERGENCY`) |
| `/manual_cmd` | geometry_msgs/msg/Twist | `web_bridge` (대시보드 조이스틱) | `patrol_node` | 10Hz | 연속 | RELIABLE | 수동 제어 모드 활성화 시 웹에서 인계하는 원격 조종 벡터 데이터 |
| `/scan` | sensor_msgs/msg/LaserScan | `turtlebot3_node` (LiDAR) | `navigation2` | 5Hz | 연속 | BEST_EFFORT | 내비게이션 및 장애물 회피를 위한 라이다 원시 데이터 |

## ⚠️ 구현 시 필수 주의사항
1. **연속 vs 엣지 구분:** `/cmd_vel` 및 `/manual_cmd` 등 연속 주행 토픽은 로봇의 안전 워치독(Watchdog)을 충족시키기 위해 반드시 최소 10Hz의 주기로 누락 없이 발행되어야 합니다.
2. **QoS 일치:** 센서류 및 실시간 상태 토픽(`/mode_status`, `/scan`)은 무통신 누적 방지를 위해 `BEST_EFFORT` 정책을 채택하였으며, 제어 토픽은 확실한 전송을 보장하기 위해 `RELIABLE`로 상호 일치시켰습니다.
