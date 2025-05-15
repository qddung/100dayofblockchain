import crypto from 'crypto';
import { Transaction } from './types';

export class Wallet {
    private privateKey: crypto.KeyObject | null = null;
    private publicKey: crypto.KeyObject | null = null;
    public address: string = "";
    private readonly publicEncodingType: string = "spki";
    private readonly publicFormat: string = "der";
    private readonly privateEncodingType: string = "pkcs8";
    private readonly privateFormat: string = "pem";

    constructor() {
        this.generateKeys();
    }

    public generateKeys(): void {
        const { privateKey, publicKey } = crypto.generateKeyPairSync('rsa', {
            modulusLength: 2048,
            publicKeyEncoding: {
                type: this.publicEncodingType,
                format: this.publicFormat
            },
            privateKeyEncoding: {
                type: this.privateEncodingType,
                format: this.privateFormat
            }
        });

        this.privateKey = crypto.createPrivateKey(privateKey);
        this.publicKey = crypto.createPublicKey(publicKey);
        this.address = this._getAddress();
    }

    public _getAddress(): string { 
        if (!this.publicKey) {
            throw new Error('No public key available');
        }
        // config get public key -- with format of wallet address
        return this.publicKey.export({ type: 'spki', format: 'der' }).toString('hex');
    }

    public signTransaction(transaction: Omit<Transaction, 'signature'>): string {
        if (!this.privateKey) {
            throw new Error('No private key available');
        }

        const sign = crypto.createSign('SHA256');
        sign.update(JSON.stringify(transaction));
        return sign.sign(this.privateKey).toString('hex');
    }

    public static verifySignature(
        transaction: Omit<Transaction, 'signature'>,
        signature: string,
        publicKeyPem: string
    ): boolean {
        try {
            const verify = crypto.createVerify('SHA256');
            verify.update(JSON.stringify(transaction));
            return verify.verify(
                publicKeyPem,
                Buffer.from(signature, 'hex')
            );
        } catch {
            return false;
        }
    }

    public getPublicKey(): string {
        if (!this.publicKey) {
            throw new Error('No public key available');
        }
        return this.publicKey.export({
            type: 'spki',
            format: 'pem'
        }).toString();
    }

    public saveToFile(filename: string): void {
        if (!this.privateKey) {
            throw new Error('No keys to save');
        }

        const keyData = this.privateKey.export({
            type: 'pkcs8',
            format: 'pem'
        });

        require('fs').writeFileSync(filename, keyData);
    }

    public static loadFromFile(filename: string): Wallet {
        const wallet = new Wallet();
        const keyData = require('fs').readFileSync(filename);
        wallet.privateKey = crypto.createPrivateKey(keyData);
        wallet.publicKey = crypto.createPublicKey(wallet.privateKey);
        wallet.address = wallet._getAddress();
        return wallet;
    }
} 