"""Budget and attempt-preservation checks; no network, GPU or benchmark execution."""
import importlib.util
import unittest
from decimal import Decimal
from pathlib import Path

spec = importlib.util.spec_from_file_location("budget", Path(__file__).with_name("staged-baseline-budget.py"))
budget = importlib.util.module_from_spec(spec)
spec.loader.exec_module(budget)


class BudgetTest(unittest.TestCase):
    def setUp(self):
        names = [f"task-{i}" for i in range(43)] + ["ms-greenfield-helpdesk", "ms-redmine-rails-upgrade", "ms-retire-proposals"]
        self.plan = {"attempts": [{"task": n, "attempt": i, "status": "not_started"}
                                 for j, n in enumerate(names) for i in range(1, 4 if j < 43 else 3)]}
        self.profiles = [{"task": n, "agent": "miniswen", "sessions": 1, "timeout": 5400,
                          "exec_timeout": 300, "build_timeout": 1800, "verifier_timeout": 600} for n in names]

    def run_plan(self, available, done=None):
        return budget.prepare(self.plan, self.profiles, done or [], available)

    def test_exact_boundary_and_one_cent_short(self):
        # 10,020 seconds at $1.50/hr rounds up to $4.18, plus $1 reserve.
        self.assertEqual(self.run_plan("5.18")["planned_this_cycle"], 4)
        self.assertEqual(self.run_plan("5.17")["planned_this_cycle"], 0)

    def test_started_unscored_never_replaced(self):
        done = [{"task": "task-0", "attempt": 1, "outcome": "unscored"}]
        result = self.run_plan("5.18", done)
        self.assertEqual(result["already_attempted"], 1)
        self.assertNotIn({"task": "task-0", "attempt": 1, "agent": "miniswen"}, result["waves"][0]["attempts"])
        self.assertEqual(result["waves"][0]["attempts"][0]["attempt"], 2)

    def test_entire_multistep_allowance_reserved(self):
        self.profiles[0]["sessions"] = 8
        self.assertEqual(self.run_plan("5.18")["planned_this_cycle"], 0)

    def test_no_future_cycle_credit_assumed(self):
        result = self.run_plan("0")
        self.assertEqual(result["planned_this_cycle"], 0)
        self.assertEqual(result["remaining_after_cycle"], 135)
        self.assertFalse(result["launch_authorized"])

    def test_aggregate_reservations_within_allowance(self):
        result = self.run_plan("19.31")
        self.assertLessEqual(sum(Decimal(w["reserved_compute_usd"]) for w in result["waves"]) + Decimal("1"), Decimal("19.31"))

    def test_invalid_inputs_fail_closed(self):
        for value in ("NaN", "Infinity", "-1"):
            with self.assertRaises(ValueError):
                self.run_plan(value)
        with self.assertRaises(ValueError):
            self.run_plan("20", [{"task": "unknown", "attempt": 1}])
        self.profiles[0]["timeout"] = float("nan")
        with self.assertRaises(ValueError):
            self.run_plan("20")


if __name__ == "__main__":
    unittest.main()
