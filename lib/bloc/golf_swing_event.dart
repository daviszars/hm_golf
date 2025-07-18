abstract class GolfSwingEvent {}

class LoadSwingsEvent extends GolfSwingEvent {}

class SelectSwingEvent extends GolfSwingEvent {
  final String swingId;

  SelectSwingEvent(this.swingId);
}

class NextSwingEvent extends GolfSwingEvent {}

class PreviousSwingEvent extends GolfSwingEvent {}

class DeleteSwingEvent extends GolfSwingEvent {
  final String swingId;

  DeleteSwingEvent(this.swingId);
}
