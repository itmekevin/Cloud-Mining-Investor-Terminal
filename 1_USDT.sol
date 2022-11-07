//SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

import "contracts/2_USDC.sol";

/*
INTENDED USAGE: This contract allows individuals to invest into a company and receive rewards after specified time intervals using USDT (could use any ERC20).
*/
contract USDT_Stuff is USDC_Stuff {

    uint256 public fundsUSDT = 0;
    uint256 public investedFundsUSDT = 0;

    mapping(address => uint256) public invest_USDT;
    mapping(address => uint256) public timeofInvest_USDT;

    IERC20 public immutable USDT;

constructor () {
    USDT = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7); //update for mainnet
    }

// INVESTING LOGIC FLOW
    function USDTInvest(uint256 investment) external payable {
        address investor = msg.sender;
        require (investedFundsUSDT + investment <= maxValueStables, "amount too high");
        require (USDT.allowance(msg.sender, address(this)) > investment);
        fundsUSDT += investment;
        investedFundsUSDT += investment;
        invest_USDT[investor] += investment;
        timeofInvest_USDT[investor] = block.number;
        USDT.transferFrom(investor, address(this), investment);
    }

    function USDTcompound() external {
        address investor = msg.sender;
        require(invest_USDT[investor] > 0, "no investment to compound");
        require(investedFundsUSDT <= maxValueStables, "amount being compounded too high");
        uint256 result = dailyRateCalcUSDT(investor);
        timeofInvest_USDT[investor] = block.number;
        invest_USDT[investor] += result;
        investedFundsUSDT += result;
    }

    function USDTcollectProfit() external {
        address investor = msg.sender;
        require(invest_USDT[investor] > 0, "no investment to collect profits for");
        uint256 result = dailyRateCalcUSDT(investor);
        if (fundsUSDT > result) {
            timeofInvest_USDT[investor] = block.number;
            fundsUSDT -= result;
            USDT.transfer(investor, result);
            } else {
                revert();
            }
    }

// CALCULATE THE DAILY RATE HERE, THEN MULTIPLY IT BY DAYS INVESTED
    function dailyRateCalcUSDT(address investor) internal view returns (uint256) {
        uint256 dailyRate = uint256((((constant1_Stables*(uint(getLatestPriceBTC())))-constant2_Stables)*invest_USDT[investor])/converter3);
        uint256 result = dailyRate * ((block.number - timeofInvest_USDT[investor])/blocksPerDay);
        return result;
    }

// FUNCTIONS TO ALLOW OWNERSHIP TO ADD AND REMOVE FUNDS FROM THE CONTRACT BALANCE
    function addLiquidityUSDT(uint256 liquidUSDT) external payable onlyAdmin {
        require (USDT.allowance(msg.sender, address(this)) > liquidUSDT, "increase allowance");
            fundsUSDT += liquidUSDT;
            USDT.transferFrom(msg.sender, address(this), liquidUSDT);
    }

    function takeFundsUSDT(address fundsDestination, uint256 liquidUSDT) external onlyAdmin {
        require (fundsDestination != address(0));
        fundsUSDT -= liquidUSDT;
        USDT.transfer(fundsDestination, liquidUSDT);
    }
    
}
