"use client";

import React from "react";
import { motion } from "framer-motion";
import { type LucideIcon } from "lucide-react";
import { cn } from "@/utils/cn";

interface FeatureCardProps {
  icon: LucideIcon;
  title: string;
  description: string;
  highlights?: string[];
  href?: string;
  index?: number;
  className?: string;
}

export default function FeatureCard({
  icon: Icon,
  title,
  description,
  highlights,
  href,
  index = 0,
  className,
}: FeatureCardProps) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 24 }}
      whileInView={{ opacity: 1, y: 0 }}
      viewport={{ once: true, margin: "-40px" }}
      transition={{ duration: 0.5, delay: index * 0.08 }}
      className={cn(
        "group bg-card-surface rounded-2xl p-6 shadow-card hover:shadow-card-hover transition-all duration-300 border border-transparent hover:border-chalk-teal/20 flex flex-col h-full",
        className
      )}
    >
      <div className="w-12 h-12 rounded-xl bg-chalk-teal/10 flex items-center justify-center mb-4 group-hover:bg-chalk-teal/20 transition-colors duration-300">
        <Icon className="w-6 h-6 text-chalk-teal" />
      </div>
      <h3 className="text-lg font-display font-semibold text-ink-green mb-2">
        {title}
      </h3>
      <p className={cn("text-sm text-ink-green/70 font-body leading-relaxed", (highlights || href) ? "mb-4" : "")}>
        {description}
      </p>

      {highlights && (
        <ul className="bg-paper rounded-xl p-4 space-y-2 mb-4">
          {highlights.map((item, i) => (
            <li key={i} className="flex items-center gap-2 text-sm text-ink-green/70 font-body">
              <span className="w-1.5 h-1.5 rounded-full bg-chalk-teal/40 flex-shrink-0" />
              {item}
            </li>
          ))}
        </ul>
      )}

      {href && (
        <a href={href} className="inline-flex items-center gap-1 text-sm font-medium text-brass-gold hover:text-brass-gold/80 transition-colors mt-auto">
          Learn more <span className="text-lg leading-none">&rarr;</span>
        </a>
      )}
    </motion.div>
  );
}
