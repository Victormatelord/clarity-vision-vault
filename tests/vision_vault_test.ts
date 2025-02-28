import {
  Clarinet,
  Tx,
  Chain,
  Account,
  types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Test content creation and retrieval",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    
    let block = chain.mineBlock([
      Tx.contractCall('vision-vault', 'save-content',
        [
          types.utf8("https://example.com"),
          types.utf8("Test Article"),
          types.ascii("article"),
          types.utf8("Test description")
        ],
        deployer.address
      )
    ]);
    
    assertEquals(block.receipts.length, 1);
    block.receipts[0].result.expectOk().expectUint(1);
    
    const response = chain.callReadOnlyFn(
      'vision-vault',
      'get-content',
      [types.uint(1)],
      deployer.address
    );
    
    response.result.expectSome();
  }
});

Clarinet.test({
  name: "Test collection creation and sharing",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    const wallet1 = accounts.get('wallet_1')!;
    
    // Create collection
    let block = chain.mineBlock([
      Tx.contractCall('vision-vault', 'create-collection',
        [
          types.utf8("Test Collection"),
          types.utf8("Test description")
        ],
        deployer.address
      )
    ]);
    
    assertEquals(block.receipts.length, 1);
    block.receipts[0].result.expectOk().expectUint(1);
    
    // Share collection
    block = chain.mineBlock([
      Tx.contractCall('vision-vault', 'share-collection',
        [
          types.uint(1),
          types.principal(wallet1.address)
        ],
        deployer.address
      )
    ]);
    
    assertEquals(block.receipts.length, 1);
    block.receipts[0].result.expectOk().expectBool(true);
  }
});

Clarinet.test({
  name: "Test adding content to collection",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    
    // Create content
    let block = chain.mineBlock([
      Tx.contractCall('vision-vault', 'save-content',
        [
          types.utf8("https://example.com"),
          types.utf8("Test Article"),
          types.ascii("article"),
          types.utf8("Test description")
        ],
        deployer.address
      )
    ]);
    
    // Create collection
    block = chain.mineBlock([
      Tx.contractCall('vision-vault', 'create-collection',
        [
          types.utf8("Test Collection"),
          types.utf8("Test description")
        ],
        deployer.address
      )
    ]);
    
    // Add content to collection
    block = chain.mineBlock([
      Tx.contractCall('vision-vault', 'add-to-collection',
        [
          types.uint(1),
          types.uint(1)
        ],
        deployer.address
      )
    ]);
    
    assertEquals(block.receipts.length, 1);
    block.receipts[0].result.expectOk().expectBool(true);
  }
});
