import ether from "./helpers/ether";
import { advanceBlock } from "./helpers/advanceToBlock";
import increaseTime, { increaseTimeTo, duration } from "./helpers/increaseTime";
import latestTime from "./helpers/latestTime";
import EVMThrow from "./helpers/EVMThrow";
import { capture, restore, Snapshot } from "./helpers/snapshot";
import timer from "./helpers/timer";
import sendTransaction from "./helpers/sendTransaction";
import "./helpers/upgradeBigNumber";

import range from "lodash/range";

const moment = require("moment");

const BigNumber = web3.BigNumber;
const eth = web3.eth;

const should = require("chai")
  .use(require("chai-as-promised"))
  .use(require("chai-bignumber")(BigNumber))
  .should();

const BankBook = artifacts.require("./BankBook.sol");
const BankBookAttack = artifacts.require("./BankBookAttack.sol");

contract("BankBookAttack", async ([ attacker, other, ...accounts ]) => {
  let bank, attack;

  const snapshot = new Snapshot();

  const txFee = ether(0.01);

  // before(snapshot.captureContracts);
  // after(snapshot.restoreContracts);

  before(async () => {
    bank = await BankBook.new();
    attack = await BankBookAttack.new(bank.address, { from: attacker });
  });

  it("any can deposit", async () => {
    await bank.deposit({ from: attacker, value: ether(1000) })
      .should.be.fulfilled;

    await bank.deposit({ from: other, value: ether(10) })
      .should.be.fulfilled;
  });

  it("anyone can withdraw", async () => {
    const beforeBalance = await eth.getBalance(other);

    await bank.withdraw(ether(0.1), { from: other })
      .should.be.fulfilled;

    await bank.withdraw(ether(0.2), { from: other })
      .should.be.fulfilled;

    await bank.withdraw(ether(0.3), { from: other })
      .should.be.fulfilled;

    const afterBalacne = await eth.getBalance(other);

    afterBalacne.should.be.bignumber.gt(
      beforeBalance.add(ether(0.6)).sub(ether(0.01)));

    (await bank.lastIndex(other))
      .should.be.bignumber.equal(3);

    (await bank.getRemainBalance(other))
      .should.be.bignumber.equal(ether(9.4));
  });

  it("attack can withdraw more than its deposit", async () => {
    const amount = ether(10);

    await attack.deposit({ value: amount })
      .should.be.fulfilled;

    (await attack.initialBalance())
      .should.be.bignumber.equal(amount);

    (await bank.getRemainBalance(attack.address))
      .should.be.bignumber.equal(amount);

    const beforeBalacne = await eth.getBalance(attack.address);

    await attack.attack(64)
      .should.be.fulfilled;

    await attack.attack(64)
      .should.be.fulfilled;

    await attack.attack(64)
      .should.be.fulfilled;

    await attack.attack(64)
      .should.be.fulfilled;

    await attack.withdraw()
      .should.be.fulfilled;

    const afterBalacne = await eth.getBalance(attack.address);

    afterBalacne.should.be.bignumber.gt(beforeBalacne.add(amount.mul(2)).sub(txFee));
  });
});
