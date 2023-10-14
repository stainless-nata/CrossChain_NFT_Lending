// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IDUSD {
    function owner() external view returns (address);
    function mint(address account, uint256 amount) external;
    function burn(address account, uint256 amount) external;
    function transferDUSD(address to, uint256 amount) external;
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function balanceOf(address account) external view returns (uint256);
    function totalSupply() external view returns (uint256);
}
