pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2; 
 

// 用作跨链的
contract MyChain {

    struct Chain {
        string chainName;
        bool state;
    }

    address public systemAdmin;
    mapping(address => bool) businessAdmin;
    event SystemAdminTransferred(address indexed preSystemAdmin, address indexed newSystemAdmin);
    event BusinessAdminChanged(address indexed businessAdmin , bool indexed changeType);
   
    mapping(uint256 => Chain) chainIdToChain;
    Chain[] public chainArray;
    event AddChain(address indexed addAddress, uint256 indexed chainId, string chainName);
    event ChangChainState(address indexed businessAddress, uint256 indexed chainId, bool indexed state);

    constructor() public {
        systemAdmin = msg.sender;
    }

    modifier onlySystemAdmin() {
        require(msg.sender == systemAdmin, "不是系统管理员");
        _;
    }

    modifier onlyBusinessAdmin() {
        require(businessAdmin[msg.sender], "不是业务管理员");
        _;
    }

    function transferSystemAdmin(address _newSystemAdmin) public onlySystemAdmin {
        require(_newSystemAdmin != address(0), "目标地址为零地址");
        emit SystemAdminTransferred(systemAdmin, _newSystemAdmin);
        systemAdmin = _newSystemAdmin;
    }

    function setBusinessAdmin(address _businessAdmin, bool _changeType) public onlySystemAdmin {
        require(_businessAdmin != address(0), "目标地址为零地址");
        businessAdmin[_businessAdmin] = _changeType;
        emit BusinessAdminChanged(_businessAdmin, _changeType);
    }

    function isBusinessAdmin(address _businessAdmin) public view returns(bool) {
        return businessAdmin[_businessAdmin];
    }
    /// 新增本合约的支持的链（合约）
    function addChain(string memory _chainName) public onlyBusinessAdmin {
        require(bytes(_chainName).length > 0,"链名称不能为空");
        require(bytes(_chainName).length <= 32,"链名称不能超过32bytes");
        uint256 newChainId = chainArray.length + 1;
        require(newChainId < 4294967296 && newChainId > 0, "");
        chainArray.length += 1;
        Chain storage ch = chainArray[newChainId - 1];
        ch.chainName = _chainName;
        ch.state = true;
        chainIdToChain[newChainId] = ch;
        emit AddChain(msg.sender, newChainId, _chainName);
    }

    /// 修改合约的支持链（合约）状态
    function setChainState(uint256 _chainId, bool _state) public onlyBusinessAdmin {
        uint256 length = chainArray.length;
        require(_chainId - 1 < length && _chainId > 0, "chainId不存在");
        Chain storage _chain = chainArray[_chainId - 1];
        require(_state != _chain.state, "不能重复修改");
        _chain.state = _state;
        emit ChangChainState(msg.sender, _chainId, _state);
    }

    /// 获取本合约支持的链（合约）
    // function getChains01() public view returns(uint256[] memory chainId,bytes32[] memory chainName, bool[] memory flags) {
    //     uint256 chainLength = chainArray.length;
    //     chainId = new uint256[](chainLength);
    //     flags = new bool[](chainLength);
    //     chainName = new bytes32[](chainLength);
    //     for (uint256 i = 0; i < chainLength; ++i) {
         
    //         chainId[i] = i + 1;
    //         string memory m = chainArray[i].chainName;
    //         bytes32 result;
    //         assembly {
    //             result := mload(add(m, 32))
    //         }
    //         chainName[i] = result;
    //         flags[i] = chainArray[i].state;
    //     }
    // }
    
      /// 获取本合约支持的链（合约）
    function getChains() public view returns(uint256[] memory chainId,string[] memory chainName, bool[] memory flags) {
        uint256 chainLength = chainArray.length;
        chainId = new uint256[](chainLength);
        flags = new bool[](chainLength);
        chainName = new string[](chainLength);
        for (uint256 i = 0; i < chainLength; ++i) {
         
            chainId[i] = i + 1;
            chainName[i] = chainArray[i].chainName;
            flags[i] = chainArray[i].state;
        }
    }
    
    

    /// 获取支持链的总数
    function getChainsCount() public view returns(uint256) {
        return chainArray.length;
    }
    
    /// 根据链ID获取链信息
    function getChain(uint256 _chainId) public view returns(string memory chainName, bool state) {
        uint256 length = chainArray.length;
        require(_chainId - 1 < length && _chainId > 0, "");
        chainName = chainIdToChain[_chainId].chainName;
        state = chainIdToChain[_chainId].state;
    }

    /// 是否启用了链
    function isEnableChain(uint256 _chainId) public view returns(bool flag) {
        uint256 length = chainArray.length;
        require(_chainId - 1 < length && _chainId > 0, "");
        flag = chainIdToChain[_chainId].state;
    }

}