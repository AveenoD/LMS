"use client";

import React from "react";
import { motion } from "framer-motion";
import { Check, Star, Building2 } from "lucide-react";
import { PRICING_PLANS, PRICING_BADGES } from "@/utils/constants";
import { cn } from "@/utils/cn";
import Button from "@/components/ui/Button";

const planIcons = [Building2, Star, Building2];

export default function PricingTable() {
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
          <span className="badge-teal mb-4 inline-block">
            Simple. Transparent. Affordable.
          </span>
          <h2 className="text-3xl sm:text-4xl lg:text-5xl font-display font-bold text-ink-green mt-4">
            Pricing Plans That{" "}
            <span className="text-gradient-gold">Grow with You.</span>
          </h2>
          <p className="mt-4 text-ink-green/60 font-body text-base max-w-lg mx-auto">
            Choose the perfect plan for your institute and start your 7-day free
            trial.
          </p>
        </motion.div>

        {/* Pricing Cards */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 lg:gap-8 mb-10">
          {PRICING_PLANS.map((plan, i) => (
            <motion.div
              key={plan.name}
              initial={{ opacity: 0, y: 24 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true, margin: "-40px" }}
              transition={{ duration: 0.5, delay: i * 0.1 }}
              className={cn(
                "relative rounded-2xl p-6 lg:p-8 border-2 transition-all duration-300",
                plan.popular
                  ? "border-ink-green bg-ink-green text-white shadow-2xl scale-[1.03] z-10"
                  : "border-paper bg-card-surface hover:border-chalk-teal/30 shadow-card"
              )}
            >
              {/* Popular Badge */}
              {plan.popular && (
                <div className="absolute -top-4 left-1/2 -translate-x-1/2">
                  <span className="bg-brass-gold text-white text-xs font-body font-semibold px-4 py-1.5 rounded-full uppercase tracking-wider">
                    Most Popular
                  </span>
                </div>
              )}

              {/* Plan Icon & Name */}
              <div className="flex items-center gap-3 mb-4">
                <div
                  className={cn(
                    "w-10 h-10 rounded-xl flex items-center justify-center",
                    plan.popular ? "bg-white/10" : "bg-chalk-teal/10"
                  )}
                >
                  {React.createElement(planIcons[i], {
                    className: cn(
                      "w-5 h-5",
                      plan.popular ? "text-brass-gold" : "text-chalk-teal"
                    ),
                  })}
                </div>
                <div>
                  <h3
                    className={cn(
                      "text-xl font-display font-bold",
                      plan.popular ? "text-white" : "text-ink-green"
                    )}
                  >
                    {plan.name}
                  </h3>
                  <p
                    className={cn(
                      "text-xs font-body",
                      plan.popular ? "text-white/60" : "text-ink-green/50"
                    )}
                  >
                    {plan.tagline}
                  </p>
                </div>
              </div>

              {/* Price */}
              <div className="mb-6">
                <div className="flex items-baseline gap-1">
                  <span
                    className={cn(
                      "text-4xl font-display font-bold",
                      plan.popular ? "text-white" : "text-ink-green"
                    )}
                  >
                    {plan.price}
                  </span>
                  <span
                    className={cn(
                      "text-sm font-body",
                      plan.popular ? "text-white/50" : "text-ink-green/40"
                    )}
                  >
                    / month
                  </span>
                </div>
                <p
                  className={cn(
                    "text-xs font-body mt-1",
                    plan.popular ? "text-white/40" : "text-ink-green/40"
                  )}
                >
                  {plan.billing}
                </p>
              </div>

              {/* Features List */}
              <ul className="space-y-3 mb-8">
                {plan.features.map((feature) => (
                  <li key={feature} className="flex items-start gap-2.5">
                    <Check
                      className={cn(
                        "w-4 h-4 mt-0.5 flex-shrink-0",
                        plan.popular ? "text-brass-gold" : "text-chalk-teal"
                      )}
                    />
                    <span
                      className={cn(
                        "text-sm font-body",
                        plan.popular ? "text-white/80" : "text-ink-green/70"
                      )}
                    >
                      {feature}
                    </span>
                  </li>
                ))}
              </ul>

              {/* CTA */}
              <Button
                variant={plan.popular ? "primary" : "secondary"}
                size="lg"
                className="w-full"
                withArrow={plan.popular}
              >
                {plan.cta}
              </Button>
            </motion.div>
          ))}
        </div>

        {/* Guarantee Badges */}
        <motion.div
          initial={{ opacity: 0 }}
          whileInView={{ opacity: 1 }}
          viewport={{ once: true }}
          transition={{ duration: 0.5, delay: 0.3 }}
          className="flex flex-wrap items-center justify-center gap-6 md:gap-10"
        >
          {PRICING_BADGES.map((badge) => (
            <div key={badge} className="flex items-center gap-2">
              <Check className="w-4 h-4 text-chalk-teal" />
              <span className="text-sm font-body text-ink-green/60">
                {badge}
              </span>
            </div>
          ))}
        </motion.div>
      </div>
    </section>
  );
}
