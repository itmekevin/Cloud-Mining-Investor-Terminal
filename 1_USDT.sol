//SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

import "contracts/USDC_Stuff.sol";


/*
INTENDED USAGE: This contract allows individuals to invest into a company and receive rewards after specified time intervals using USDT (could use any ERC20).
*/
contract USDT_Stuff is USDC_Stuff {

    uint256 public fundsUSDT = 0;
    uint256 public timeIn_USDT = 0;
    uint256 public investedFundsUSDT = 0;

    mapping(address => uint256) public invest_USDT;
    mapping(address => uint256) public timeofInvest_USDT;
    mapping(address => uint256) public investmentRewardsUSDT; 

    IERC20 public USDT;

constructor () {
    USDT = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    }

// INVESTING LOGIC FLOW
    function USDTInvest(uint256 investment) public payable {
        require (investedFundsUSDT + investment <= maxValueStables);
        address investor = msg.sender;
        fundsUSDT += investment;
        investedFundsUSDT += investment;
        invest_USDT[investor] += investment;
        timeofInvest_USDT[investor] = block.timestamp;
        USDT.transferFrom(investor, address(this), investment);
    }

    function USDTcompound() public {
        address investor = msg.sender;
        require(invest_USDT[investor] > 0);
        require(investedFundsUSDT <= maxValueStables);
        timeIn_USDT = block.timestamp - timeofInvest_USDT[investor];
        dailyRateCalcUSDT(investor);
        timeofInvest_USDT[investor] = block.timestamp;
        invest_USDT[investor] += investmentRewardsUSDT[investor];
        investedFundsUSDT += investmentRewardsUSDT[investor];
    }

    function USDTcollectProfit() public {
        address investor = msg.sender;
        require(invest_USDT[investor] > 0);
        timeIn_USDT = block.timestamp - timeofInvest_USDT[investor];
        dailyRateCalcUSDT(investor);
        timeofInvest_USDT[investor] = block.timestamp;
        fundsUSDT -= investmentRewardsUSDT[investor];
        USDT.transfer(investor, investmentRewardsUSDT[investor]);
    }

// CALCULATE THE DAILY RATE HERE, THEN MULTIPLY IT BY DAYS INVESTED
    function dailyRateCalcUSDT(address investor) internal {
        uint256 dailyRate = uint256((((constant1_Stables*(uint(getLatestPriceBTC())))-constant2_Stables)*invest_USDT[investor])/10000000000000000000);
        investmentRewardsUSDT[investor] = dailyRate * (timeIn_USDT/6375);
    }

// FUNCTIONS TO ALLOW OWNERSHIP TO ADD AND REMOVE FUNDS FROM THE CONTRACT BALANCE
    function addLiquidityUSDT(uint256 liquidUSDT) public payable onlyAdmin {
        fundsUSDT += liquidUSDT;
        USDT.transferFrom(msg.sender, address(this), liquidUSDT);
    }

    function takeFundsUSDT(address payable fundsDestination, uint256 liquidUSDT) public onlyAdmin {
        fundsUSDT -= liquidUSDT;
        USDT.transfer(fundsDestination, liquidUSDT);
    }

}