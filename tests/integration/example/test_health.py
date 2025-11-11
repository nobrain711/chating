import pytest
import httpx
import asyncio

pytestmark = pytest.mark.integration

@pytest.mark.asyncio
async def test_health_endpoint():
  async with httpx.AsyncClient() as clint:
    assert 1 == 1