Given(/^a clean set of benchmarks$/) do
  drop_all_tables
  create_benchmarks
end
