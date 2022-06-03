# DinelliMining
Investing Portal for a BTC Mining Company

0_MiningContract.sol is the deployable contract for this investment portal. It manages the ETH invested into the contract and the respective calculators and payouts for ETH. USDT and USDC do the same for their respective coins, and are both inherited by MiningContract. AdminStatus simply creates the modifier which permissions specific functions for the admins, and PriceChecker pulls prices for BTC and ETH necessary for calculations done by the other contracts.
