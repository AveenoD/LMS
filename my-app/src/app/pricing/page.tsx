import type { Metadata } from "next";
import PricingTable from "@/components/sections/PricingTable";
import ComparisonTable from "@/components/sections/ComparisonTable";
import CTABanner from "@/components/sections/CTABanner";
import FAQSection from "@/components/sections/FAQSection";

export const metadata: Metadata = {
  title: "Pricing — EdTech OS",
  description:
    "Simple, transparent, affordable pricing plans for EdTech OS. Start your 7-day free trial today.",
};

export default function PricingPage() {
  return (
    <>
      <PricingTable />
      <ComparisonTable />
      <CTABanner
        variant="dark"
        title="Not sure which plan is right for you?"
        subtitle="Book a free demo and our expert will help you choose the best plan for your institute."
      />
      <FAQSection />
    </>
  );
}
