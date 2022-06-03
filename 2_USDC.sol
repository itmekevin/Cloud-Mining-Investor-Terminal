//SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "contracts/AdminStatus.sol";
import "contracts/BTC_and_ETH_Price.sol";

/*
INTENDED USAGE: This contract allows individuals to invest into a company and receive rewards after specified time intervals using USDC (could use any ERC20).
*/
contract USDC_Stuff is AdminStatus, BTC_Oracle_Test {

    uint256 public constant1_Stables = 4104;
    uint256 public constant2_Stables = 9576000000000000;
    uint256 public maxValueStables = 50000000000;
    uint256 public fundsUSDC = 0;
    uint256 public investedFundsUSDC = 0;
    uint256 public timeIn_USDC = 0;

    mapping(address => uint256) public invest_USDC;
    mapping(address => uint256) public timeofInvest_USDC;
    mapping(address => uint256) public investmentRewardsUSDC; 

    IERC20 public USDC;

constructor () {
    USDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    }

// INVESTING LOGIC FLOW
    function USDCInvest(uint256 investment) public payable {
        require (investedFundsUSDC + investment <= maxValueStables);
        address investor = msg.sender;
        fundsUSDC += investment;
        investedFundsUSDC += investment;
        invest_USDC[investor] += investment;
        timeofInvest_USDC[investor] = block.number;
        USDC.transferFrom(investor, address(this), investment);
    }

    function USDCcompound() public {
        address investor = msg.sender;
        require(invest_USDC[investor] > 0);
        require(investedFundsUSDC <= maxValueStables);
        timeIn_USDC = block.number - timeofInvest_USDC[investor];
        dailyRateCalcUSDC(investor);
        timeofInvest_USDC[investor] = block.number;
        invest_USDC[investor] += investmentRewardsUSDC[investor];
        investedFundsUSDC += investmentRewardsUSDC[investor];
    }

    function USDCcollectProfit() public {
        address investor = msg.sender;
        require(invest_USDC[investor] > 0);
        timeIn_USDC = block.number - timeofInvest_USDC[investor];
        dailyRateCalcUSDC(investor);
        timeofInvest_USDC[investor] = block.number;
        fundsUSDC -= investmentRewardsUSDC[investor];
        USDC.transfer(investor, investmentRewardsUSDC[investor]);
    }

// CALCULATE THE DAILY RATE HERE, THEN MULTIPLY IT BY DAYS INVESTED (timeIn_USDC / blocks per day)
    function dailyRateCalcUSDC(address investor) internal {
        uint256 dailyRate = uint256((((constant1_Stables*(uint(getLatestPriceBTC())))-constant2_Stables)*invest_USDC[investor])/10000000000000000000);
        investmentRewardsUSDC[investor] = dailyRate * (timeIn_USDC/6375);
    }

// SET CONSTANTS FOR dailyRateCalcUSDC
    function setconstant1_Stables(uint256 changeconstant1_Stables) public onlyAdmin {
        constant1_Stables = changeconstant1_Stables;
    }

    function setconstant2_Stables(uint256 changeconstant2_Stables) public onlyAdmin {
        constant2_Stables = changeconstant2_Stables;
    }

// FUNCTIONS TO ALLOW OWNERSHIP TO ADD AND REMOVE FUNDS FROM THE CONTRACT BALANCE
    function addLiquidityUSDC(uint256 liquidUSDC) public payable onlyAdmin {
        fundsUSDC += liquidUSDC;
        USDC.transferFrom(msg.sender, address(this), liquidUSDC);
    }

    function takeFundsUSDC(address payable fundsDestination, uint256 liquidUSDC) public onlyAdmin {
        fundsUSDC -= liquidUSDC;
        USDC.transfer(fundsDestination, liquidUSDC);
    }

    function setMaxValueStables(uint256 newMaxValue) public onlyAdmin {
        maxValueStables = newMaxValue;
    }
}