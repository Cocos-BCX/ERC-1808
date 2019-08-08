export default async (promise, expectedRevertMessage="") => {
  try {
    await promise;
    return
  } catch (error) {
    let invalidOpcode = false;
    let outOfGas = false;
    let revert = false;
    if (expectedRevertMessage !== "") {
      // Check end of error string, it's where the revert reason is output.
      let expectedLen = expectedRevertMessage.length;
      if (expectedLen < error.message.length) {
          // Rather annoyingly, truffle adds a period if it can decode the revert reason.
          if (error.message.search('-- Reason given:') >= 0) {
            revert = expectedRevertMessage === error.message.substring(error.message.length-expectedLen-1, error.message.length-1);
          } else {
            revert = expectedRevertMessage === error.message.substring(error.message.length-expectedLen, error.message.length);
          }
      }
    } else {
      // TODO: Check jump destination to destinguish between a throw
      //       and an actual invalid jump.
      invalidOpcode = error.message.search('invalid opcode') >= 0;
      // TODO: When we contract A calls contract B, and B throws, instead
      //       of an 'invalid jump', we get an 'out of gas' error. How do
      //       we distinguish this from an actual out of gas event? (The
      //       testrpc log actually show an 'invalid jump' event.)
      outOfGas = error.message.search('out of gas') >= 0;
      revert = error.message.search('revert') >= 0;
    }

    assert(
      invalidOpcode || outOfGas || revert,
      'Expected throw with revert string \'' + expectedRevertMessage + '\', got \'' + error + '\' instead',
    );
    return;
  }
  assert.fail('Expected throw not received');
};
