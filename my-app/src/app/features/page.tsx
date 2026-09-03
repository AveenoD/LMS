import type { Metadata } from "next";
import DetailedFeaturesGrid from "@/components/sections/DetailedFeaturesGrid";
import CTABanner from "@/components/sections/CTABanner";

export const metadata: Metadata = {
  title: "Features — Campus",
  description:
    "Explore all the powerful features of Campus: Dashboard, Students Management, Attendance, Fees, Live Classes, Tests & Exams, and more.",
};

export default function FeaturesPage() {
  return (
    <>
      <DetailedFeaturesGrid />
      <CTABanner
        variant="dark"
        title="One Platform. Every Operation. Better Management. Bigger Impact."
        subtitle="Your data is safe with us. Automate routine tasks and focus on teaching."
      />
    </>
  );
}
