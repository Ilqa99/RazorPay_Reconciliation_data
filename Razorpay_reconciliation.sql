Razorpay Payment Reconciliation:


STEP 1: Create Database
CREATE DATABASE razorpay_reconcil;
USE razorpay_reconcil;

STEP 2: Create Tables
CREATE TABLE razorpay_data (
    Payment_id          VARCHAR(50) PRIMARY KEY,
    Payment_date        DATE,
    Merchant_name       VARCHAR(100),
    Transaction_amount  DECIMAL(12,2),
    Add_on_commission   DECIMAL(12,2),
    Currency_code       VARCHAR(10),
    Partner_name        VARCHAR(50),
    Payment_method      VARCHAR(50)
);

CREATE TABLE graphy_data (
    Payment_id              VARCHAR(50) PRIMARY KEY,
    Inr_revshare_txn_amount DECIMAL(12,2),
    Rev_share_charges_db    DECIMAL(12,2)
);

STEP 3: Core Reconciliation Query
SELECT
    payment_id,
    payment_date,
    merchant_name,
    transaction_amount,
    add_on_commission                              AS razorpay_figure,
    inrRevShareTxnAmount                           AS graphy_figure,
    ROUND(add_on_commission - inrRevShareTxnAmount, 2) AS difference,

    CASE
        WHEN inrRevShareTxnAmount IS NULL
            THEN 'Missing in Graphy DB'
        WHEN add_on_commission = inrRevShareTxnAmount
            THEN 'Verified'
        WHEN add_on_commission > inrRevShareTxnAmount
            THEN 'Less Revshare on DB'
        WHEN add_on_commission < inrRevShareTxnAmount
            THEN 'Less Revshare on Razorpay'
    END AS remark

FROM razorpay_reconciliation_sample
ORDER BY remark;

STEP 4: Save as View (reusable every month)
CREATE VIEW monthly_reconciliation AS
SELECT
    payment_id,
    payment_date,
    merchant_name,
    add_on_commission        AS razorpay_figure,
    inrRevShareTxnAmount     AS graphy_figure,
    ROUND(add_on_commission - inrRevShareTxnAmount, 2) AS difference,
    CASE
        WHEN inrRevShareTxnAmount IS NULL             THEN 'Missing in Graphy DB'
        WHEN add_on_commission = inrRevShareTxnAmount THEN 'Verified'
        WHEN add_on_commission > inrRevShareTxnAmount THEN 'Less Revshare on DB'
        WHEN add_on_commission < inrRevShareTxnAmount THEN 'Less Revshare on Razorpay'
    END AS remark
FROM razorpay_reconciliation_sample;

STEP 5: Monthly Summary Report
SELECT
    remark,
    COUNT(*)                       AS transaction_count,
    SUM(ABS(difference))           AS total_discrepancy_inr,
    ROUND(AVG(ABS(difference)), 2) AS avg_discrepancy_inr
FROM monthly_reconciliation
GROUP BY remark
ORDER BY transaction_count DESC;
