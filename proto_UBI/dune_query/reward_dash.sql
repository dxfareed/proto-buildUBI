-- 1. Total BUILD Claimed
SELECT SUM(amount) AS total_build_claimed
FROM ethereum.public.logs
WHERE contract_address = ' 0xF21ad20ACBe2Bdd5E1E70aC02F765229b9941BD0'  
  AND topic = '0x' || SUBSTR(keccak256('ClaimRewardUser(address,uint256)'), 3);

-- 2. Total BUILD Claimed per Week
SELECT
    DATE_TRUNC('week', block_time) AS week,  
    SUM(amount) AS weekly_build_claimed
FROM ethereum.public.logs
WHERE contract_address = ' 0xF21ad20ACBe2Bdd5E1E70aC02F765229b9941BD0'  
  AND topic = '0x' || SUBSTR(keccak256('ClaimRewardUser(address,uint256)'), 3)
GROUP BY week
ORDER BY week;

-- 3. Claimants per Week
SELECT
    DATE_TRUNC('week', block_time) AS week, 
    COUNT(DISTINCT _user) AS claimants_per_week 
FROM ethereum.public.logs
WHERE contract_address = ' 0xF21ad20ACBe2Bdd5E1E70aC02F765229b9941BD0'
  AND topic = '0x' || SUBSTR(keccak256('ClaimRewardUser(address,uint256)'), 3)
GROUP BY week
ORDER BY week;

-- 4. Top Claimants (All Time)
WITH Claims AS (
    SELECT _user, SUM(amount) AS total_claimed  
    FROM ethereum.public.logs
    WHERE contract_address = ' 0xF21ad20ACBe2Bdd5E1E70aC02F765229b9941BD0'  
      AND topic = '0x' || SUBSTR(keccak256('ClaimRewardUser(address,uint256)'), 3)
    GROUP BY _user
)
SELECT _user, total_claimed
FROM Claims
ORDER BY total_claimed DESC
LIMIT 10;

-- 5. Claims Over Time (Daily)
SELECT
    DATE(block_time) AS claim_date,
    SUM(amount) AS daily_build_claimed
FROM ethereum.public.logs
WHERE contract_address = ' 0xF21ad20ACBe2Bdd5E1E70aC02F765229b9941BD0'  
  AND topic = '0x' || SUBSTR(keccak256('ClaimRewardUser(address,uint256)'), 3)
GROUP BY claim_date
ORDER BY claim_date;

-- 6. Total BUILD Deposited (Donations)
SELECT SUM(amount) AS total_build_deposited
FROM ethereum.public.logs
WHERE contract_address = ' 0xF21ad20ACBe2Bdd5E1E70aC02F765229b9941BD0'  
  AND topic = '0x' || SUBSTR(keccak256('DepositBuild(uint256)'), 3);

-- 7. Donations by Donor
SELECT sender, SUM(amount) AS total_donated
FROM ethereum.public.logs
WHERE contract_address = ' 0xF21ad20ACBe2Bdd5E1E70aC02F765229b9941BD0'
  AND topic = '0x' || SUBSTR(keccak256('DepositBuild(uint256)'), 3)
GROUP BY sender
ORDER BY total_donated DESC;