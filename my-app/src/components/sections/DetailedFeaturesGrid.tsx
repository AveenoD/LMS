"use client";

import React from "react";
import { motion } from "framer-motion";
import { ArrowRight } from "lucide-react";
import { DETAILED_FEATURES } from "@/utils/constants";
import { cn } from "@/utils/cn";

export default function DetailedFeaturesGrid() {
  return (
    <section className="bg-gradient-to-b from-white to-[#F4F6F3] pt-4 pb-12 md:pt-6 md:pb-20">
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
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true, margin: "-60px" }}
              transition={{ duration: 0.45, delay: i * 0.05, ease: "easeOut" }}
              className="group relative bg-white rounded-2xl p-5 md:p-6 shadow-md hover:shadow-2xl border border-chalk-teal/10 hover:border-chalk-teal/30 transition-all duration-300 flex flex-col overflow-hidden"
            >
              {/* Top Accent Line */}
              <div className="absolute top-0 left-0 right-0 h-1.5 bg-gradient-to-r from-chalk-teal to-brass-gold opacity-0 group-hover:opacity-100 transition-opacity duration-300" />

              {/* Icon & Title */}
              <div className="flex flex-col gap-4 mb-4">
                <div className="w-12 h-12 rounded-xl bg-chalk-teal text-white flex items-center justify-center group-hover:scale-110 transition-transform duration-300 shadow-md">
                  <feature.icon className="w-6 h-6" />
                </div>
                <h3 className="text-lg font-display font-bold text-ink-green group-hover:text-chalk-teal transition-colors duration-300">
                  {feature.title}
                </h3>
              </div>

              {/* Description */}
              <p className="text-sm text-ink-green/70 font-body leading-relaxed mb-5">
                {feature.description}
              </p>

              {/* Highlights */}
              <div className="bg-chalk-teal/5 rounded-xl p-4 mb-5 flex-1 border border-chalk-teal/10">
                <div className="space-y-2.5">
                  {feature.highlights.map((hl, j) => (
                    <div
                      key={j}
                      className="flex items-start gap-2.5 text-sm font-medium text-ink-green/80 font-body"
                    >
                      <div className="w-1.5 h-1.5 rounded-full bg-brass-gold mt-1.5 flex-shrink-0" />
                      <span className="leading-tight">{hl}</span>
                    </div>
                  ))}
                </div>
              </div>

              {/* Link */}
              <div className="mt-auto">
                <button className="inline-flex items-center gap-1.5 text-sm font-body font-bold text-chalk-teal group-hover:text-brass-gold transition-colors">
                  Learn more
                  <ArrowRight className="w-4 h-4 group-hover:translate-x-1 transition-transform" />
                </button>
              </div>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
}
