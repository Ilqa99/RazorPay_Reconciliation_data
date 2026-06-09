RazorPay Payment Reconciliation — SQL Project

Problem Statement:
Every month, the company receives a payment report from Razorpay with which finance team manually verified 1000+ transactions to find mismatches between Razorpay figures and internal DB figures taking several hours each month.

Solution:
Built an automated SQL reconciliation pipeline that compares
Razorpay's commission figures with Graphy's internal DB and
auto-generates remarks for every transaction.

Impact:
Reduced manual reconciliation effort from hours to seconds.
Automatically flags revenue discrepancies across all transactions.

Steps:
1. Monthly Razorpay export is loaded into MySQL
2. Query compares `add_on_commission` vs `inrRevShareTxnAmount`
3. CASE logic auto-generates a remark for each row
4. Summary report flags total discrepancy amount

Remark Logic:
1. Verified: Both figures match exactly
2. Less Revshare on DB: Razorpay shows more than Company DB 
3. Less Revshare on Razorpay: Company DB shows more than Razorpay
4. Missing in Company DB: Transaction exists in Razorpay but not in Company DB

Key SQL Concepts Used:
 `CASE WHEN` for conditional remark generation
 `LEFT JOIN` for matching transactions across two sources
 `COALESCE` for handling NULL values
 `ROUND` for financial precision
 `CREATE VIEW` for reusable monthly reporting

Files: `Razorpay_reconciliation.sql` — full pipeline: table creation, reconciliation query, view, summary report

Context:
Built during Data Analyst internship (2026)
See also: [SaaS Affiliate Revenue SQL](https://github.com/Ilqa99/saas-affiliate-revenue-sql)
