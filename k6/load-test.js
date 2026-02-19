import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '30s', target: 20 },  // Ramp up to 20 users
    { duration: '1m', target: 50 },   // Ramp up to 50 users
    { duration: '2m', target: 50 },   // Stay at 50 users
    { duration: '30s', target: 0 },   // Ramp down to 0 users
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'], // 95% of requests should be below 500ms
    http_req_failed: ['rate<0.01'],   // Error rate should be less than 1%
  },
};

const BASE_URL = __ENV.BASE_URL || 'http://localhost:8080';

export default function () {
  // Test 1: Health check
  const healthRes = http.get(`${BASE_URL}/health`);
  check(healthRes, {
    'health check status is 200': (r) => r.status === 200,
  });

  sleep(1);

  // Test 2: Evaluate hand
  const evaluatePayload = JSON.stringify({
    holeCards: ['HA', 'HK'],
    boardCards: ['HQ', 'HJ', 'HT', 'D2', 'C3'],
  });

  const evaluateRes = http.post(`${BASE_URL}/api/evaluate`, evaluatePayload, {
    headers: { 'Content-Type': 'application/json' },
  });

  check(evaluateRes, {
    'evaluate hand status is 200': (r) => r.status === 200,
    'evaluate hand returns bestHand': (r) => JSON.parse(r.body).bestHand !== undefined,
  });

  sleep(1);

  // Test 3: Compare hands
  const comparePayload = JSON.stringify({
    player1: {
      holeCards: ['HA', 'HK'],
      boardCards: ['HQ', 'HJ', 'HT', 'D2', 'C3'],
    },
    player2: {
      holeCards: ['SA', 'SK'],
      boardCards: ['HQ', 'HJ', 'HT', 'D2', 'C3'],
    },
  });

  const compareRes = http.post(`${BASE_URL}/api/compare`, comparePayload, {
    headers: { 'Content-Type': 'application/json' },
  });

  check(compareRes, {
    'compare hands status is 200': (r) => r.status === 200,
    'compare hands returns winner': (r) => JSON.parse(r.body).winner !== undefined,
  });

  sleep(1);

  // Test 4: Monte Carlo simulation
  const monteCarloPayload = JSON.stringify({
    holeCards: ['HA', 'HK'],
    boardCards: ['HQ', 'HJ'],
    numPlayers: 6,
    numSimulations: 1000,
  });

  const monteCarloRes = http.post(`${BASE_URL}/api/montecarlo`, monteCarloPayload, {
    headers: { 'Content-Type': 'application/json' },
  });

  check(monteCarloRes, {
    'monte carlo status is 200': (r) => r.status === 200,
    'monte carlo returns winProbability': (r) => JSON.parse(r.body).winProbability !== undefined,
  });

  sleep(2);
}
