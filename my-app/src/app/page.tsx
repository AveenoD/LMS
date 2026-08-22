import HeroSection from "@/components/sections/HeroSection";
import KeyFeaturesSection from "@/components/sections/KeyFeaturesSection";
import CTABanner from "@/components/sections/CTABanner";

export default function HomePage() {
  return (
    <>
      <HeroSection />
      <KeyFeaturesSection />
      <CTABanner variant="teal" />
    </>
  );
}
