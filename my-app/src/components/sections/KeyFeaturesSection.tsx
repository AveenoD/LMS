"use client";

import React from "react";
import { motion } from "framer-motion";
import FeatureCard from "@/components/ui/FeatureCard";
import { KEY_FEATURES } from "@/utils/constants";

export default function KeyFeaturesSection() {
  return (
    <section className="bg-paper pb-16 md:pb-24 pt-4 md:pt-8">
      <div className="container-main">
        {/* Section Header */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.5 }}
          className="text-center mb-12"
        >
          <span className="badge-gold mb-4 inline-block">Key Features</span>
          <h2 className="text-3xl sm:text-4xl font-display font-bold text-ink-green mt-4">
            Everything You Need to Run Your Institute
          </h2>
        </motion.div>

        {/* Feature Grid */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
          {KEY_FEATURES.map((feature, i) => (
            <FeatureCard
              key={feature.title}
              icon={feature.icon}
              title={feature.title}
              description={feature.description}
              highlights={feature.highlights}
              href={feature.href}
              index={i}
            />
          ))}
        </div>
      </div>
    </section>
  );
}
