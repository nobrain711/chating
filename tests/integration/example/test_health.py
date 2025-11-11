import pytest
import asyncpg

pytestmark = pytest.mark.integration

@pytest.mark.asyncio
async def test_db_connection():
  conn = await asyncpg.connect(
    user = 'master',
    password = 'test_password',
    database = 'test_db',
    host = 'db',
    port = 5432
  )
  
  result = await conn.fetchval("select 1;")
  await conn.close()
  assert result == 1