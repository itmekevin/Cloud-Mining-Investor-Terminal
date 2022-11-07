// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract BTC_Oracle_Test {


    AggregatorV3Interface internal priceFeed;
    AggregatorV3Interface internal priceFeedETH;

    /**
     * Network: Goerli
     * Aggregator: BTC/USD
     * Address: 0x6135b13325bfC4B00278B4abC5e20bbce2D6580e
     */
    constructor() {
        priceFeed = AggregatorV3Interface(0xA39434A63A52E749F02807ae27335515BA4b07F7);
        priceFeedETH = AggregatorV3Interface(0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e);
    }

    /**
     * Returns the latest price
     */
    function getLatestPriceBTC() public view returns (int) {
        (
            /*uint80 roundID*/, 
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();
        return price;
    }

        function getLatestPriceETH() public view returns (int) {
        (
            /*uint80 roundID*/, 
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = priceFeedETH.latestRoundData();
        return price;
    }

}
