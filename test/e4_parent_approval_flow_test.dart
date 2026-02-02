import 'package:flutter_test/flutter_test.dart';
import 'package:mytime/timechoice/timechoice.dart';

import 'package:mytime/ui/demo_app_state.dart';

void main() {
  group('E.4B parent approval flow (in-memory)', () {
    test('pending -> approved keeps DTOs valid', () {
      final r = CompletedMissionRecord(
        missionId: 'm_1',
        completedAtUtc: DateTime.utc(2026, 1, 1),
        actualTimeSpentMin: 20,
        outcome: WorldOutcome.completed,
        approvalState: ParentApprovalState.pending,
      );

      final approved = r.copyWith(approvalState: ParentApprovalState.approved);

      expect(approved.approvalState, ParentApprovalState.approved);
      expect(approved.missionId, 'm_1');
      expect(approved.actualTimeSpentMin, 20);
      expect(approved.outcome, WorldOutcome.completed);
    });

    test('pending list filter works', () {
      final s = DemoAppState.initial();

      final s2 = s.copyWith(
        completed: [
          CompletedMissionRecord(
            missionId: 'a',
            completedAtUtc: DateTime.utc(2026, 1, 1),
            actualTimeSpentMin: 10,
            outcome: WorldOutcome.completed,
            approvalState: ParentApprovalState.pending,
          ),
          CompletedMissionRecord(
            missionId: 'b',
            completedAtUtc: DateTime.utc(2026, 1, 1),
            actualTimeSpentMin: 10,
            outcome: WorldOutcome.completed,
            approvalState: ParentApprovalState.approved,
          ),
        ],
      );

      expect(s2.pendingApprovals.length, 1);
      expect(s2.pendingApprovals.first.missionId, 'a');
    });
  });
}
