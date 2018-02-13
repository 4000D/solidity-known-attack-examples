import ether from "./helpers/ether";
import { advanceBlock } from "./helpers/advanceToBlock";
import increaseTime, { increaseTimeTo, duration } from "./helpers/increaseTime";
import latestTime from "./helpers/latestTime";
import EVMThrow from "./helpers/EVMThrow";
import { capture, restore, Snapshot } from "./helpers/snapshot";
import timer from "./helpers/timer";
import sendTransaction from "./helpers/sendTransaction";
import "./helpers/upgradeBigNumber";

const moment = require("moment");

const BigNumber = web3.BigNumber;
const eth = web3.eth;

const should = require("chai")
  .use(require("chai-as-promised"))
  .use(require("chai-bignumber")(BigNumber))
  .should();

const EtherVault = artifacts.require("./EtherVault.sol");
const EtherVaultAttack = artifacts.require("./EtherVaultAttack.sol");

contract("EtherVaultAttack", async ([ attacker, other, ...accounts ]) => {
  let vault, attack;

  const snapshot = new Snapshot();

  // before(snapshot.captureContracts);
  // after(snapshot.restoreContracts);

  before(async () => {
    vault = await EtherVault.new();
    attack = await EtherVaultAttack.new(vault.address, { from: attacker });
  });

  it("any can deposit", async () => {
    await vault.deposit({ from: attacker, value: 1 })
      .should.be.fulfilled;

    await vault.deposit({ from: other, value: 1 })
      .should.be.fulfilled;

    await attack.deposit({ value: 1 })
      .should.be.fulfilled;
  });

  it("attack can withdraw more than his deposit", async () => {
    const beforeBalacne = await eth.getBalance(attack.address);
    const deposit = await vault.deposits(attack.address);

    await attack.withdraw()
      .should.be.fulfilled;

    const afterBalacne = await eth.getBalance(attack.address);

    afterBalacne.should.be.bignumber.gt(beforeBalacne.add(deposit));
  });
});
