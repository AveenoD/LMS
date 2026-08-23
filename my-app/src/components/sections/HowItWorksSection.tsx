"use client";

import React from "react";
import { motion } from "framer-motion";
import { Clock, Users, Zap, LayoutDashboard } from "lucide-react";
import { HOW_IT_WORKS_STEPS, USP_ITEMS } from "@/utils/constants";

const stepIcons = [Clock, Zap, Users, LayoutDashboard];

export default function HowItWorksSection() {
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
          <span className="badge-teal mb-4 inline-block">Simple. Fast. Powerful.</span>
          <h2 className="text-3xl sm:text-4xl lg:text-5xl font-display font-bold text-ink-green mt-4">
            How EdTech OS{" "}
            <span className="text-gradient-gold">Works</span>
          </h2>
          <p className="mt-4 text-ink-green/60 font-body text-base max-w-md mx-auto">
            Get your institute up and running in 4 simple steps.
          </p>
        </motion.div>

        {/* Steps Grid */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6 mb-16">
          {HOW_IT_WORKS_STEPS.map((step, i) => {
            const StepIcon = stepIcons[i];
            return (
              <motion.div
                key={step.step}
                initial={{ opacity: 0, y: 20 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true, margin: "-60px" }}
                transition={{ duration: 0.45, delay: i * 0.07, ease: "easeOut" }}
                className="relative bg-card-surface rounded-2xl p-6 shadow-card border border-transparent hover:border-chalk-teal/20 transition-[box-shadow,border-color] duration-300 group"
              >
                {/* Step Number */}
                <div className="w-10 h-10 rounded-xl bg-ink-green text-white flex items-center justify-center font-display font-bold text-lg mb-6">
                  {step.step}
                </div>

                {/* Illustration placeholder */}
                <div className="w-full h-32 bg-paper rounded-xl mb-5 flex items-center justify-center overflow-hidden">
                  <StepIcon className="w-12 h-12 text-chalk-teal/40" />
                </div>

                {/* Content */}
                <h3 className="text-lg font-display font-semibold text-ink-green mb-2">
                  {step.title}
                </h3>
                <p className="text-sm text-ink-green/60 font-body leading-relaxed mb-4">
                  {step.description}
                </p>

                {/* Subtext */}
                <div className="flex items-center gap-2 text-xs text-ink-green/50 font-body">
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
