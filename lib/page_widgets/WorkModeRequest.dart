class WorkModeRequest {
  int fk_sender_id;
  int fk_recipient_id;
  DateTime start_time;
  int duration;

  WorkModeRequest(int fk_sender_id, int fk_recipient_id, DateTime start_time, int duration) {
    this.fk_sender_id = fk_sender_id;
    this.fk_recipient_id = fk_recipient_id;
    this.start_time = start_time;
    this.duration = duration;
  }

  @override
  String toString() {
    return "Sid :" + fk_sender_id.toString() + " Rid: " + fk_recipient_id.toString() + " st: " + start_time.toIso8601String() + " d: " + duration.toString();
  }
}