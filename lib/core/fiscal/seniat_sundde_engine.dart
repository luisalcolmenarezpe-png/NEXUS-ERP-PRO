import 'package:decimal/decimal.dart';

enum IvaRate {
  general('0.16'),
  reduced('0.08'),
  additional('0.31'),
  exempt('0.0');

  final String rateStr;
  const IvaRate(this.rateStr);
  Decimal get rate => Decimal.parse(rateStr);
}

class SeniatInvoiceCalculation {
  final Decimal subtotal;
  final IvaRate ivaRate;
  final Decimal ivaAmount;
  final bool igtfApplies;
  final Decimal igtfRate;
  final Decimal igtfAmount;
  final Decimal grandTotal;

  SeniatInvoiceCalculation({
    required this.subtotal,
    required this.ivaRate,
    required this.ivaAmount,
    required this.igtfApplies,
    required this.igtfRate,
    required this.igtfAmount,
    required this.grandTotal,
  });
}

class SunddeValidation {
  final bool isCompliant;
  final Decimal actualMargin;
  final Decimal maxAllowedPrice;
  final Decimal excessAmount;

  SunddeValidation({
    required this.isCompliant,
    required this.actualMargin,
    required this.maxAllowedPrice,
    required this.excessAmount,
  });
}

class FiscalSummary {
  final SeniatInvoiceCalculation seniatCalculation;
  final SunddeValidation sunddeValidation;
  final Decimal retentionAmount;

  FiscalSummary({
    required this.seniatCalculation,
    required this.sunddeValidation,
    required this.retentionAmount,
  });
}

class SeniatSunddeEngine {
  static final Decimal maxProfitMarginSundde = Decimal.parse('0.30'); // 30% max

  static SeniatInvoiceCalculation calculateInvoiceTax(Decimal subtotal, IvaRate rate, bool isForeignCurrencyCash) {
    Decimal ivaAmount = subtotal * rate.rate;
    bool igtfApplies = isForeignCurrencyCash;
    Decimal igtfRate = Decimal.parse('0.03');
    Decimal igtfAmount = igtfApplies ? subtotal * igtfRate : Decimal.zero;
    Decimal grandTotal = subtotal + ivaAmount + igtfAmount;

    return SeniatInvoiceCalculation(
      subtotal: subtotal,
      ivaRate: rate,
      ivaAmount: ivaAmount,
      igtfApplies: igtfApplies,
      igtfRate: igtfRate,
      igtfAmount: igtfAmount,
      grandTotal: grandTotal,
    );
  }

  static SunddeValidation validateSunddeMargin(Decimal costUsd, Decimal salePriceUsd) {
    Decimal actualMargin = costUsd > Decimal.zero ? (salePriceUsd - costUsd) / costUsd : Decimal.zero;
    Decimal maxAllowedPrice = calculateMaxAllowedPrice(costUsd);
    bool isCompliant = actualMargin <= maxProfitMarginSundde;
    Decimal excessAmount = isCompliant ? Decimal.zero : salePriceUsd - maxAllowedPrice;

    return SunddeValidation(
      isCompliant: isCompliant,
      actualMargin: actualMargin,
      maxAllowedPrice: maxAllowedPrice,
      excessAmount: excessAmount,
    );
  }

  static Decimal calculateMaxAllowedPrice(Decimal costUsd) {
    return costUsd * (Decimal.one + maxProfitMarginSundde);
  }

  static Decimal calculateFiscalRetention(Decimal invoiceTotal, {bool isSpecialContributor = false}) {
    Decimal retentionRate = isSpecialContributor ? Decimal.one : Decimal.parse('0.75');
    // Assuming calculation based on total for simplicity, standard requires calculation on IVA part.
    return invoiceTotal * retentionRate; 
  }

  static FiscalSummary generateCompleteFiscalSummary(
    Decimal subtotal, 
    Decimal cost, 
    Decimal salePrice, 
    IvaRate ivaRate, 
    bool isForeignCash, 
    bool isSpecialContributor
  ) {
    return FiscalSummary(
      seniatCalculation: calculateInvoiceTax(subtotal, ivaRate, isForeignCash),
      sunddeValidation: validateSunddeMargin(cost, salePrice),
      retentionAmount: calculateFiscalRetention(subtotal * ivaRate.rate, isSpecialContributor: isSpecialContributor),
    );
  }
}
