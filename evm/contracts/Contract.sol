pragma solidity ^0.8.20;

contract Storage {
    uint public value;

    event ValueChanged(uint oldValue, uint newValue);

    function setValue(uint _value) public {
        uint oldValue = value;
        
        value = _value;

        emit ValueChanged(oldValue, _value);
    }

    function getValue() public view returns (uint) {
        return value;
    }
}