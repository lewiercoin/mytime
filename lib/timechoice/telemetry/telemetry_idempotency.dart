import '../dto/telemetry.dart';
import '../enums/telemetry_event_type.dart';

class TelemetryIdempotency {
  static String keyForEnvelope(TelemetryEnvelope e) {
    return '${e.snapshotId}:${e.eventType.name}';
  }

  static TelemetryEventType typeOf(Object event) {
    return switch (event) {
      LoopStartedEvent _ => TelemetryEventType.loopStarted,
      FramePresentedEvent _ => TelemetryEventType.framePresented,
      OptionSelectedEvent _ => TelemetryEventType.optionSelected,
      WorldOutcomeRecordedEvent _ => TelemetryEventType.worldOutcomeRecorded,
      LoopUpdatedEvent _ => TelemetryEventType.loopUpdated,
      _ => throw StateError('Unknown event type'),
    };
  }

  static TelemetryEnvelope envelopeOf(Object event) {
    return switch (event) {
      LoopStartedEvent x => x.envelope,
      FramePresentedEvent x => x.envelope,
      OptionSelectedEvent x => x.envelope,
      WorldOutcomeRecordedEvent x => x.envelope,
      LoopUpdatedEvent x => x.envelope,
      _ => throw StateError('Unknown event type'),
    };
  }
}
