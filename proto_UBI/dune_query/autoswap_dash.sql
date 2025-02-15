-- 1. Total ETH Donated
SELECT SUM(ethAmount) AS total_eth_donated
FROM ethereum.public.logs
WHERE contract_address = '0x2a7096f07749096ff70F3F50ba20097506642Bf6'
  AND topic = '0x' || SUBSTR(keccak256('DonationReceived(address,uint256)'), 3);

-- 2. Total BUILD Received (after swap)
SELECT SUM(amountOut) AS total_build_received
FROM ethereum.public.logs
WHERE contract_address = '0x2a7096f07749096ff70F3F50ba20097506642Bf6' 
  AND topic = '0x' || SUBSTR(keccak256('SwapExecuted(uint256,uint256)'), 3);

-- 3. Top Supporters (by ETH donated)
WITH Donations AS (
    SELECT donor, SUM(ethAmount) AS total_eth_donated
    FROM ethereum.public.logs
    WHERE contract_address = '0x2a7096f07749096ff70F3F50ba20097506642Bf6'
      AND topic = '0x' || SUBSTR(keccak256('DonationReceived(address,uint256)'), 3)
    GROUP BY donor
)
SELECT donor, total_eth_donated
FROM Donations
ORDER BY total_eth_donated DESC
LIMIT 10;

-- 4. Number of Donations
SELECT COUNT(DISTINCT tx_hash) AS number_of_donations
FROM ethereum.public.logs
WHERE contract_address = '0x2a7096f07749096ff70F3F50ba20097506642Bf6'
  AND topic = '0x' || SUBSTR(keccak256('DonationReceived(address,uint256)'), 3);

-- 5. Donations Over Time (Daily)
SELECT
    DATE(block_time) AS donation_date,
    SUM(ethAmount) AS daily_eth_donated
FROM ethereum.public.logs
WHERE contract_address = '0x2a7096f07749096ff70F3F50ba20097506642Bf6'
  AND topic = '0x' || SUBSTR(keccak256('DonationReceived(address,uint256)'), 3)
GROUP BY donation_date
ORDER BY donation_date;

-- 6. Withdrawals (ERC20)
SELECT to, token, amount
FROM ethereum.public.logs
WHERE contract_address = '0x2a7096f07749096ff70F3F50ba20097506642Bf6'
  AND topic = '0x' || SUBSTR(keccak256('Withdraw(address,address,uint256)'), 3);

-- 7. WETH Withdrawals
SELECT to, amount
FROM ethereum.public.logs
WHERE contract_address = '0x2a7096f07749096ff70F3F50ba20097506642Bf6'
  AND topic = '0x' || SUBSTR(keccak256('Withdraw(address,address,uint256)'), 3)
  AND token = '0x4200000000000000000000000000000000000006'; -- WETH address