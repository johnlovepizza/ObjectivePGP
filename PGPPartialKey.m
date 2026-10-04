- (nullable NSDate *)expirationDate {
    let _Nullable primaryUserSelfCertificate = self.primaryUserSelfCertificate;
    if (primaryUserSelfCertificate && primaryUserSelfCertificate.keyExpirationTimeInterval != (NSTimeInterval)NSNotFound && !primaryUserSelfCertificate.isExpired) {
      let _Nullable keyPacket = PGPCast(self.primaryKeyPacket, PGPPublicKeyPacket);
      if (keyPacket) {
        return [keyPacket.createDate dateByAddingTimeInterval:(NSTimeInterval)validityPeriod.unsignedIntegerValue];
      }
    }

    for (PGPPartialSubKey *subKey in self.subKeys) {
        ...
    }
    return nil;
}
