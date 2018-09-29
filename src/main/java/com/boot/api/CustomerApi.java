package com.boot.api;

import java.net.URI;
import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

import com.boot.entity.Customer;
import com.boot.exception.CustomerNotFoundException;
import com.boot.repo.CustomerRepository;

@RestController
public class CustomerApi {

	@Autowired
	private CustomerRepository customerRepository;
	
	@Value("${spring.datasource.password}")
	private String password;

	

	@GetMapping("/password")
	public String getPassword() {
		return password;
	}
	@GetMapping("/customers")
	public List<Customer> retrieveAllCustomers() {
		return customerRepository.findAll();
	}
	
	@GetMapping("/customer/{id}")
	public Customer retrieveCustomer(@PathVariable long id) {
		Optional<Customer> customer = customerRepository.findById(id);

		if (!customer.isPresent())
			throw new CustomerNotFoundException("id-" + id);

		return customer.get();
	}
	
	@DeleteMapping("/customer/{id}")
	public void deleteCcustomer(@PathVariable long id) {
		customerRepository.deleteById(id);
	}
	
	@PostMapping("/customer")
	public ResponseEntity<Object> createCustomer(@RequestBody Customer customer) {
		Customer savedCustomer = customerRepository.save(customer);

		URI location = ServletUriComponentsBuilder.fromCurrentRequest().path("/{id}")
				.buildAndExpand(savedCustomer.getId()).toUri();

		return ResponseEntity.created(location).build();

	}
	
	@PutMapping("/customer/{id}")
	public ResponseEntity<Object> updateCustomer(@RequestBody Customer customer, @PathVariable long id) {

		Optional<Customer> customerOptional = customerRepository.findById(id);
		if (!customerOptional.isPresent())
			return ResponseEntity.notFound().build();

		customer.setId(id);
		
		customerRepository.save(customer);

		return ResponseEntity.noContent().build();
	}
}
