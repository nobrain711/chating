import os
import pytest

@pytest.fixture(scope="session", autouse=True)
def _setup_env():
  os.environ.setdefault("PYTHONUNBUFFERED", "1")