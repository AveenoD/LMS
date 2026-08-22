"use client";

import React from "react";
import { motion } from "framer-motion";
import { ArrowRight } from "lucide-react";
import { DETAILED_FEATURES } from "@/utils/constants";
import { cn } from "@/utils/cn";

export default function DetailedFeaturesGrid() {
  return (
    <section className="bg-white pt-4 pb-12 md:pt-6 md:pb-16">
      <div className="container-main">
        {/* Section Header */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.5 }}
          className="text-center mb-8 md:mb-10"
        >
          <span className="badge-gold mb-4 inline-block">Powerful Features</span>
          <h1 className="text-3xl sm:text-4xl lg:text-5xl font-display font-bold text-ink-green mt-4">
            Everything You Need to Run
            <br />
            <span className="text-gradient-gold">Your Institute, Effortlessly.</span>
          </h1>
          <p className="mt-4 text-ink-green/60 font-body text-base max-w-lg mx-auto">
            All the tools you need to manage, automate and grow your coaching
            institute.
          </p>
        </motion.div>

        {/* Features Grid */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 md:gap-5">
          {DETAILED_FEATURES.map((feature, i) => (
            <motion.div
              key={feature.title}
              initial={{ opacity: 0, y: 24 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true, margin: "-40px" }}
              transition={{ duration: 0.5, delay: i * 0.06 }}
              className="group bg-card-surface rounded-2xl p-4 md:p-5 shadow-card hover:shadow-card-hover border border-transparent hover:border-chalk-teal/20 transition-all duration-300 flex flex-col"
            >
              {/* Icon */}
              <div className="flex items-center gap-3 mb-3">
                <div className="w-10 h-10 rounded-xl bg-chalk-teal/10 flex items-center justify-center group-hover:bg-chalk-teal/20 transition-colors">
                  <feature.icon className="w-5 h-5 text-chalk-teal" />
                </div>
                <h3 className="text-base font-display font-semibold text-ink-green">
                  {feature.title}
                </h3>
              </div>

              {/* Description */}
              <p className="text-sm text-ink-green/60 font-body leading-relaxed mb-3">
                {feature.description}
              </p>

              {/* Preview placeholder */}
              <div className="bg-paper rounded-xl p-3 mb-3 flex-1">
                <div className="space-y-2">
                  {feature.highlights.map((hl, j) => (
                    <div
                      key={j}
                      className="flex items-center gap-2 text-xs text-ink-green/50 font-body"
                    >
                      <div className="w-1.5 h-1.5 rounded-full bg-chalk-teal/40" />
                      {hl}
                    </div>
                  ))}
                </div>
              </div>

              {/* Link */}
              <div className="mt-auto">
                <button className="inline-flex items-center gap-1.5 text-sm font-body font-medium text-brass-gold hover:gap-2.5 transition-all">
                  Learn more
                  <ArrowRight className="w-3.5 h-3.5" />
                </button>
              </div>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
}
