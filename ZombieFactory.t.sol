// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {ZombieFactory} from "../src/ZombieFactory.sol";

contract ZombieFactoryTest is Test {

    ZombieFactory factory;

    address alice = address(0xA11CE);
    address bob = address(0xB0B);


    function setUp() public {
        factory = new ZombieFactory();
    }



    // тут все фунции для тестирования должны начинаться с префикса test
    function testCreateZombieSuccess() public {
        // vm вызывает контракт от имени владельца(alice или Bob) - передается  m.sender(отправитель)

        vm.prank(alice);
        uint256 id = factory.createZombie("Alice");

        assertEq(id, 0, "Первый зомби с id = 0 должен быть");
        assertEq(factory.totalZombies(), 1);
        assertEq(factory.ownerZombieCount(alice), 1); // у Алисы на данный моментт 1 зомби
        assertEq(factory.zombieToOwner(id), alice); // у зомби по данному id хозяин Алиса

        (string memory name, uint256 dna, uint256 createdAt) = factory.getZombie(id); // структура
        assertEq(name, "Alice");
        assertLt(dna, 10 ** 16); // ДНК меньше должен быть чем 10 ** 16
        assertEq(createdAt, block.timestamp); 
    }


    function testTwoDifferentOwners() public {
        vm.prank(alice);
        uint256 id1 = factory.createZombie("Alice");

        vm.prank(bob);
        uint256 id2 = factory.createZombie("Bob");

        assertEq(id1, 0);
        assertEq(id2, 1);
        assertEq(factory.totalZombies(), 2);
        assertEq(factory.zombieToOwner(id1), alice);
        assertEq(factory.zombieToOwner(id2), bob);
    }



    function testEmptyNameReverts() public {
        vm.prank(alice);
        vm.expectRevert("Empty name"); // проверка что исключение будет 
        factory.createZombie("");
    }


    function testAlreadyHasZombieReverts() public {
        vm.prank(alice);
        factory.createZombie("Alice");

        vm.prank(alice);
        vm.expectRevert("Already has zombie");
        factory.createZombie("Another");
    }


    function testDnaLessThanModulus() public {
        vm.prank(alice);
        uint256 id = factory.createZombie("Alice");


        (, uint256 dna, ) = factory.getZombie(id); // ДНК меньше должен быть чем 10 ** 16
        assertLt(dna, 10 ** 16);
    }
}


