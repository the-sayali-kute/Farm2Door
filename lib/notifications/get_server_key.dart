import 'package:googleapis_auth/auth_io.dart';

class GetServerKey {
  Future<String> getServerKeyToken() async {
    final scopes = [
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/firebase.database',
      'https://www.googleapis.com/auth/firebase.messaging',
    ];

    final client = await clientViaServiceAccount(
      ServiceAccountCredentials.fromJson({
        "type": "service_account",
        "project_id": "farm-to-door-auth",
        "private_key_id": "c1161e4410860806f0e07ce685d922c6dd75ed3f",
        "private_key":
            "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC9pHZXAjNTbsNm\nVlJvMH5gTplUPN+XINV41mkU36QPdo8ahjiBlgd68ZGNw7j4hsGuvWsHqEG4+N47\n33S21+5o+xpMDw4lj1cwHV7qOcSesCiDa1DedhS6gzU4JlgEXf9Z2GrKixgLgg0t\n8n0AFjIwjrHCv7ZwMSrwR7FXMS5VUA4rSjehPzfqhBM5ZE6SOer/E2x2hBedP2U+\nokMNqaWKKJ9spHeVN8cND88kolHUicVKmHiWbYB+tkGPi1MOLCNYutTRcwzcvgI4\n/bl+DyO+Xr+Bhl8KoYcS8/ycXbcZJO932XYyDUh0U/rMqeEDuEHMV4875rIalSnf\naU/wgxe7AgMBAAECggEAIxR4G5I5olZb6ONQ7mZ/Chuf+1gjWBZnxqmK2KSh+YZJ\n5HMtorL5AUIMVbf90GNFEqjRUqJKPggzO8oTEfuRi3PfonAqgsIoM6tLMnKrL1uQ\nsva4B9656OJ6hr95Cp3ErX7+Cid+tCpDe9teShTRBfBva4IBInHF6pqocGOVmYwa\n4oSND5KpWb0x2ei/RY4T+ymdoAJKHicdUCCyVjiIX2tiRRDGegfesETwGZtz6usO\nnGKXRSxNbQDiJ6/J4Mol2LWsR9FPsAh+iwp6EwBOBpe7oBlqH703sr7eUyTvu/JM\nzo85vSxwYi3vS4GmzMlZelsymfUPZYO/BeCgYk0u8QKBgQDoDjk3Q5hwM4wDBmFb\naDj9gPFkQea+y1lpo3jqvfQ9AKyYaw4QdYsr77XRJ3Dq9ZSf1N95qrFPbPXt2c+f\nIwD02kPSJ7pPhFKH4iAvYuVixB4iD3lqHgxloImoSnwS+t2zNIYfMtR1kVkX4uN0\n13Wx9UlSTRr7Kq+arSz8F23X6QKBgQDRNeQCn2pS+N0ABYNbmhBEs0rrOE/YZhd9\n+gSyhkGcp49ggt03qDVtmtYA+eMW31EvBDcSJGaXoKnwk0Aiz/LOpcCfwyJFalK3\ne4Yc9sVM26NU9GzoOsrSWAdEwaXG/BbcoKlXtN2bsfYE/IyTscdnEc9Es1Z3V452\nQ+Aq/QMQAwKBgEqemENvFwutZ65pVNEh2IGb/wNwNZTQqvXPPUiuwGUFXHq+og0k\n3xXHxT12Y1cKlTo4J4xmGRIjRYmwapUPmnUh4oEniT+cmzVav2K9eGmkCtSFCVPY\nScA8OUfGe9NWnAfOMfrCS5Nqo62MpfuidRQ+fc9bP/vYJBOm8Do4BnhRAoGADPkq\nin8YOMz152pwGt4S5C+6FZwIV4L9MfKvF+L7bpt1aKa00R69MW7IlobobiKrBh9c\nyuM2+XAdGa4H7CC5Ddd5em6/UU6mkno2dtVWps1382y01DHRIfoTeVAI164KPOQ5\nnBa7J0yB1Q1UKlR76QhRshDs67miO/M5k3DdH8ECgYEA23yshurZ0/Tw0MWn58EQ\n/Tr6xvsa8bCkir+j0kXTTZZ6e+tyapsmnf83LWC2qPD0kmGkadquz3sKnscS90dz\n8Q1w8/u01VDhtYLePsX+WFodlMZYzD+EHXRBusx0+TNpdw6QIOBFch1LR0jT6ahA\nBzsMgH4pMQzds9mg1esH6F0=\n-----END PRIVATE KEY-----\n",
        "client_email":
            "firebase-adminsdk-fbsvc@farm-to-door-auth.iam.gserviceaccount.com",
        "client_id": "101776300191052214834",
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://oauth2.googleapis.com/token",
        "auth_provider_x509_cert_url":
            "https://www.googleapis.com/oauth2/v1/certs",
        "client_x509_cert_url":
            "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40farm-to-door-auth.iam.gserviceaccount.com",
        "universe_domain": "googleapis.com",
      }),
      scopes,
    );
    final accessServerKey = client.credentials.accessToken.data;
    return accessServerKey;
  }
}
