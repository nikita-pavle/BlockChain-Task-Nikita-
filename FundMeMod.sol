// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

//chainlink integration was removed to simplify the conract

error NotOwner();

contract FundMe {
    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;

    // Could we make this constant?  /* hint: no! We should make it immutable! */
    address public /*immutable*/   i_owner;
    uint256 public constant MINIMUM_USD = 50 * 10 ** 18;
    
    constructor() {
        i_owner = msg.sender;
    }

    function fund() public payable {
        require(msg.value >= MINIMUM_USD, "You need to spend more ETH!");
        // require(PriceConverter.getConversionRate(msg.value) >= MINIMUM_USD, "You need to spend more ETH!");
        addressToAmountFunded[msg.sender] += msg.value;
        if(addressToAmountFunded[msg.sender]==msg.value){
            //if address already exists in the array, it wont be added again as balance will be modified and hence if condition not satisfied
        funders.push(msg.sender);
        }
    }
    
    
    modifier onlyOwner {
        // require(msg.sender == owner);
        if (msg.sender != i_owner) revert NotOwner();
        _;
    }
    
    function withdraw() public onlyOwner {
        for (uint256 funderIndex=0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
        // // transfer
        // payable(msg.sender).transfer(address(this).balance);
        // // send
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed");
        // call
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }
    // Explainer from: https://solidity-by-example.org/fallback/
    // Ether is sent to contract
    //      is msg.data empty?
    //          /   \ 
    //         yes  no
    //         /     \
    //    receive()?  fallback() 
    //     /   \ 
    //   yes   no
    //  /        \
    //receive()  fallback()
    function transfer(address newOwner) public   onlyOwner{//function can be accessed only by owner ensuring that no one else attempts to transfer ownership
        require(newOwner != address(0),"Invalid Address"); //checks if it is a valid address
        i_owner = newOwner;   //changes ownership address to the new address 

    }

    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }

}
