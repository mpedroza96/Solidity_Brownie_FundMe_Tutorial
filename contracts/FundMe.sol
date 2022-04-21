// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol"; //Protect againts overflow for version < 0.8

contract Fundme {
    using SafeMathChainlink for uint256;

    mapping(address => uint256) public addressToAmountFounded;
    address[] public funders;
    address owner;
    AggregatorV3Interface public priceFeed;

    constructor(address _priceFeed) public {
        owner = msg.sender;
        priceFeed = AggregatorV3Interface(_priceFeed);
    }

    function fund() public payable {
        uint256 minimumUsd = 50 * 10**18;
        require(
            getConversionRate(msg.value) >= minimumUsd,
            "You need to spend more ETH!"
        );
        addressToAmountFounded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }

    function getVersion() public view returns (uint256) {
        return priceFeed.version();
    }

    function getPrice() public view returns (uint256) {
        //Tuple definition
        // (uint80 roundId,
        // int256 answer,
        // uint256 startedAt,
        // uint256 updatedAt,
        // uint80 answeredInRound) = priceFeed.latestRoundData();

        //Single Tuple
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        return uint256(answer * 10**10);
    }

    function getConversionRate(uint256 ethAmount)
        public
        view
        returns (uint256)
    {
        uint256 ethPrice = getPrice();
        uint256 ethUsd = (ethPrice * ethAmount) / (10**18);
        return ethUsd;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function withdraw() public payable onlyOwner {
        msg.sender.transfer(address(this).balance);
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            addressToAmountFounded[funders[funderIndex]] = 0;
        }
        funders = new address[](0);
    }

    function getEntranceFee() public view returns (uint256) {
        uint256 minimumUSD = 50 * 10**18;
        uint256 price = getPrice();
        uint256 precision = 1 * 10**18;
        return (minimumUSD * precision) / price;
    }
}
