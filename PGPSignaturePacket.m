- (nullable NSDate *)expirationDate {
    let _Nullable creationDate = self.creationDate;
    if (!creationDate) {
        return nil;
    }

    let _Nullable validityPeriodSubpacket = PGPCast([self subpacketsOfType:PGPSignatureSubpacketTypeSignatureExpirationTime].firstObject, PGPSignatureSubpacket);
    let _Nullable validityPeriod = PGPCast(validityPeriodSubpacket.value, NSNumber);
    if (!validityPeriod || validityPeriod.unsignedIntegerValue == 0) {
        return nil;
    }

    return [creationDate dateByAddingTimeInterval:(NSTimeInterval)validityPeriod.unsignedIntegerValue];
}

- (NSTimeInterval)keyExpirationTimeInterval {
   let _Nullable validityPeriodSubpacket = PGPCast([self subpacketsOfType:PGPSignatureSubpacketTypeKeyExpirationTime].firstObject, PGPSignatureSubpacket);
   let _Nullable validityPeriod = PGPCast(validityPeriodSubpacket.value, NSNumber);
   if (!validityPeriod || validityPeriod.unsignedIntegerValue == 0) {
     return (NSTimeInterval)NSNotFound;
   }

   return validityPeriod.doubleValue;
}
