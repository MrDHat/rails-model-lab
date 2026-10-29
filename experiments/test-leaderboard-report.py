import importlib.util
from pathlib import Path
import unittest

spec = importlib.util.spec_from_file_location("report", Path(__file__).with_name("leaderboard-report.py"))
report = importlib.util.module_from_spec(spec)
spec.loader.exec_module(report)


class ReportingTest(unittest.TestCase):
    def setUp(self):
        self.plan = {"attempts": [{"task": t} for t in ["a", "a", "a", "b", "b"]]}
        self.results = [{"task": t, "trial": str(i), "outcome": {"scored": True},
                         "reward": 1, "credit": c} for i, (t, c) in enumerate([
                             ("a", 0.1), ("a", 0.1), ("a", 0.1), ("b", 1), ("b", 1)])]

    def test_equal_task_credit_not_binary_reward_or_run_weighting(self):
        self.assertAlmostEqual(report.summarize(self.plan, self.results)["accuracy_percent"], 55)

    def test_unscored_is_not_zero_or_a_complete_score(self):
        self.results[-1] = {"task": "b", "trial": "4", "outcome": {"scored": False}}
        result = report.summarize(self.plan, self.results)
        self.assertFalse(result["complete"])
        self.assertIsNone(result["accuracy_percent"])
        self.assertIsNone(result["attempts"][-1]["credit"])

    def test_missing_attempt_prevents_headline(self):
        self.assertIsNone(report.summarize(self.plan, self.results[:-1])["accuracy_percent"])

    def test_duplicate_and_extra_attempts_rejected(self):
        with self.assertRaises(ValueError):
            report.summarize(self.plan, self.results + self.results[:1])
        with self.assertRaises(ValueError):
            report.summarize(self.plan, self.results + [{**self.results[0], "trial": "extra"}])

    def test_mixed_models_rejected(self):
        self.results[0]["model"] = "other-model"
        with self.assertRaises(ValueError):
            report.summarize(self.plan, self.results)

    def test_frozen_model_required_when_declared(self):
        self.plan["model"] = "frozen-model"
        with self.assertRaises(ValueError):
            report.summarize(self.plan, self.results)


if __name__ == "__main__":
    unittest.main()
