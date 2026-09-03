import type { Metadata } from "next";
import HowItWorksSection from "@/components/sections/HowItWorksSection";
import CTABanner from "@/components/sections/CTABanner";

export const metadata: Metadata = {
  title: "How It Works — Campus",
  description:
    "Get your institute up and running in 4 simple steps. Book a demo, quick setup, add users, and start managing.",
};

export default function HowItWorksPage() {
  return (
    <>
      <HowItWorksSection />
      <CTABanner variant="teal" />
    </>
  );
}
