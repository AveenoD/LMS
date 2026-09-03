"use client";

import React from "react";
import { motion } from "framer-motion";
import { Clock, Users, Zap, LayoutDashboard } from "lucide-react";
import { HOW_IT_WORKS_STEPS, USP_ITEMS } from "@/utils/constants";

const stepIcons = [Clock, Zap, Users, LayoutDashboard];

export default function HowItWorksSection() {
  return (
    <section className="bg-gradient-to-b from-[#F4F6F3] to-white pt-4 pb-12 md:pt-6 md:pb-16">
      <div className="container-main">
        {/* Section Header */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.5 }}
          className="text-center mb-8 md:mb-10"
        >
          <span className="badge-teal mb-4 inline-block">Simple. Fast. Powerful.</span>
          <h2 className="text-3xl sm:text-4xl font-display font-bold text-ink-green mt-3">
            How Campus{" "}
            <span className="text-gradient-gold">Works</span>
          </h2>
          <p className="mt-4 text-ink-green/60 font-body text-base max-w-md mx-auto">
            Get your institute up and running in 4 simple steps.
          </p>
        </motion.div>

        {/* Steps Grid */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5 mb-14">
          {HOW_IT_WORKS_STEPS.map((step, i) => {
            const StepIcon = stepIcons[i];
            return (
              <motion.div
                key={step.step}
                initial={{ opacity: 0, y: 20 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true, margin: "-60px" }}
                transition={{ duration: 0.45, delay: i * 0.07, ease: "easeOut" }}
                className="group relative bg-white rounded-2xl p-6 shadow-md hover:shadow-2xl border border-chalk-teal/10 hover:border-chalk-teal/30 transition-all duration-300 flex flex-col overflow-hidden"
              >
                {/* Top Accent Line */}
                <div className="absolute top-0 left-0 right-0 h-1.5 bg-gradient-to-r from-chalk-teal to-brass-gold opacity-0 group-hover:opacity-100 transition-opacity duration-300 z-10" />

                {/* Step Number */}
                <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-ink-green to-chalk-teal text-white flex items-center justify-center font-display font-bold text-lg mb-6 shadow-md relative z-10">
                  {step.step}
                </div>

                {/* Illustration placeholder */}
                <div className="w-full h-32 bg-chalk-teal/5 rounded-xl mb-5 flex items-center justify-center overflow-hidden border border-chalk-teal/10 group-hover:bg-chalk-teal/10 transition-colors duration-300 relative">
                  <div className="absolute inset-0 bg-[radial-gradient(circle_at_center,rgba(46,102,86,0.05)_0%,transparent_70%)] opacity-0 group-hover:opacity-100 transition-opacity duration-300" />
                  <StepIcon className="w-14 h-14 text-chalk-teal group-hover:scale-110 group-hover:text-ink-green transition-all duration-500 relative z-10" />
                </div>

                {/* Content */}
                <h3 className="text-lg font-display font-bold text-ink-green group-hover:text-chalk-teal transition-colors duration-300 mb-2">
                  {step.title}
                </h3>
                <p className="text-sm text-ink-green/70 font-body leading-relaxed mb-5">
                  {step.description}
                </p>

                {/* Subtext */}
                <div className="mt-auto pt-4 border-t border-dashed border-chalk-teal/10 flex items-center gap-2 text-xs font-medium text-brass-gold font-body">
                  <Clock className="w-3.5 h-3.5" />
                  {step.subtext}
                </div>
              </motion.div>
            );
          })}
        </div>

        {/* USP Bar */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.5 }}
          className="bg-chalk-teal rounded-2xl p-6 md:p-8"
        >
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
            {USP_ITEMS.map((item) => (
              <div key={item.title} className="flex items-start gap-3">
                <div className="w-10 h-10 rounded-xl bg-white/10 flex items-center justify-center flex-shrink-0">
                  <item.icon className="w-5 h-5 text-white" />
                </div>
                <div>
                  <p className="text-sm font-body font-semibold text-white">
                    {item.title}
                  </p>
                  <p className="text-xs text-white/70 font-body mt-0.5">
                    {item.description}
                  </p>
                </div>
              </div>
            ))}
          </div>
        </motion.div>
      </div>
    </section>
  );
}
