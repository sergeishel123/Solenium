
pragma solidity ^0.8.20;

contract ZombieFactory {
    struct Zombie {
        string name; 
        uint256 dna; // ДНК зомбака
        uint256 createdAt; 
    }

    uint256 public constant DNA_MODULUS = 10 ** 16; // по модулю, ну тут ДНК не може превышать 10 ^ 16

    


    // вообще address - это тип данных(адрес здес будет адресом владельца зомби)
    Zombie[] private zombies; // зомбоки
    mapping(uint256 => address) public zombieToOwner; // словарь - по id зомби можно буде узнать adress(владельца)
    mapping(address => uint256) public ownerZombieCount; // дабы нельзя одному владельцу иметь больше 1 зомби, то будем подсчиывать

    /*
    event контракт записывает в лог блокчейна
    События  остаются в истории блокчейна и  их можно слушать снаружи.
    */
    // id и ownner будут наверное индексируемыми, т.к будем проводить фильттрацию и поиск наверное

    event ZombieCreated(uint256 indexed id, address indexed owner, string name, uint256 dna);
 


    // external - можно извне обращаться, по завершению возвращаем id зомби
    // но требует calldata или memory для строковых параметров- до конца не понял почему, исключение при компиляции выдавало

    function createZombie(string calldata name) external returns (uint256 id) {
        require(bytes(name).length > 0, "Empty name");
        require(ownerZombieCount[msg.sender] == 0, "Already has zombie"); // тут у владельца лишь 1 зомби масимум


        uint256 dna = uint256(keccak256(abi.encodePacked(msg.sender, name))) % DNA_MODULUS;  // по модулю, ибо масимум 10 ^ 16 

        id = zombies.length; // id присваивае следующим за последним из существующих просто
        zombies.push(Zombie({
            name: name,
            dna: dna,
            createdAt: block.timestamp
        }));

        zombieToOwner[id] = msg.sender;
        ownerZombieCount[msg.sender] = 1;


        emit ZombieCreated(id, msg.sender, name, dna); // событие иницииуруем

        return id;
    }

    function totalZombies() external returns (uint256) {
        return zombies.length;
    } 

    function getZombie(uint256 id ) external returns(string memory, uint256, uint256){
        Zombie z = zombies[id];

        // тут еще блин не получается просто возвраиь z,только так
        return (z.name, z.dna, z.createdAt);
    } 

    // 

}
